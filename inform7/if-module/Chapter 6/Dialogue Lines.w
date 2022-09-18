[DialogueLines::] Dialogue Lines.

To manage dialogue lines.

@h Scanning the dialogue lines in pass 0.
Lines have already been parsed a little. For example,
= (text as Inform 7)
	Marcellus (this is the phantom line): "What, has this thing appear'd again to-night?"
=
will have become:
= (text)
	DIALOGUE_LINE_NT
		DIALOGUE_SPEAKER_NT "Marcellus"
		DIALOGUE_SPEECH_NT ""What, has this thing appear'd again to-night?""
		DIALOGUE_CLAUSE_NT "this is the phantom line"
=
Here we have a simple tree where the beat node has at least two child nodes:
exactly one each of |DIALOGUE_SPEAKER_NT| and |DIALOGUE_SPEECH_NT|, and then
any number of |DIALOGUE_CLAUSE_NT| nodes (including none at all).

=
dialogue_line *DialogueLines::new(parse_node *PN) {
	int L = Annotations::read_int(PN, dialogue_level_ANNOT);
	if (L < 0) L = 0;
	dialogue_line *dl = CREATE(dialogue_line);
	@<Initialise the line@>;
	@<Parse the clauses just enough to classify them@>;
	@<Look for a line name@>;
	dl->as_node = DialogueNodes::add_to_current_beat(L, dl, NULL);
	@<Add the line to the world model@>;
	return dl;
}

@ =
typedef struct dialogue_line {
	struct wording line_name;
	struct instance *as_instance;
	struct parse_node *line_at;
	int narration;
	int without_speaking;
	struct wording speaker_text;
	struct wording speech_text;
	struct parse_node *speaker_description;
	struct linked_list *mentioning; /* of |parse_node| */
	struct performance_style *how_performed;
	struct instance *interlocutor;
	struct dialogue_node *as_node;
	struct dialogue_line_compilation_data compilation_data;
	CLASS_DEFINITION
} dialogue_line;

@<Initialise the line@> =
	dl->line_name = EMPTY_WORDING;
	dl->line_at = PN;
	dl->narration = FALSE;
	dl->speaker_text = EMPTY_WORDING;
	dl->speaker_description = NULL;
	dl->without_speaking = FALSE;
	dl->compilation_data = RTDialogueLines::new(PN, dl);
	dl->speech_text = EMPTY_WORDING;
	dl->mentioning = NEW_LINKED_LIST(parse_node);
	dl->how_performed = NULL;
	dl->interlocutor = NULL;

@<Parse the clauses just enough to classify them@> =
	for (parse_node *clause = PN->down; clause; clause = clause->next) {
		wording CW = Node::get_text(clause);
		if (Node::is(clause, DIALOGUE_CLAUSE_NT)) {
			<dialogue-line-clause>(CW);
			Annotations::write_int(clause, dialogue_line_clause_ANNOT, <<r>>);
		} else if (Node::is(clause, DIALOGUE_SPEAKER_NT)) {
			if (<dialogue-is-narration>(CW))
				dl->narration = TRUE;
			else
				dl->speaker_text = CW;
		} else if (Node::is(clause, DIALOGUE_SPEECH_NT)) {
			dl->speech_text = CW;
		} else internal_error("damaged DIALOGUE_LINE_NT subtree");
	}

@ The special speaker "narration" marks out a line which isn't a speech at all:

=
<dialogue-is-narration> ::=
	narration

@ As with the analogous clauses for //Dialogue Beats//, each clause can be one
of the following possibilities:

@e LINE_NAME_DLC from 1
@e MENTIONING_DLC
@e IF_DLC
@e UNLESS_DLC
@e BEFORE_DLC
@e AFTER_DLC
@e NOW_DLC
@e TO_DLC
@e WITHOUT_SPEAKING_DLC
@e ENDING_DLC
@e ENDING_SAYING_DLC
@e ENDING_FINALLY_DLC
@e ENDING_FINALLY_SAYING_DLC
@e STYLE_DLC

@<Look for a line name@> =
	int dialogue_line_name_count = 0;
	for (parse_node *clause = PN->down; clause; clause = clause->next) {
		wording CW = Node::get_text(clause);
		switch (Annotations::read_int(clause, dialogue_line_clause_ANNOT)) {
			case LINE_NAME_DLC:	
				<dialogue-line-clause>(CW);
				dl->line_name = GET_RW(<dialogue-line-clause>, 1);
				dialogue_line_name_count++;
				break;
		}
	}
	if (dialogue_line_name_count > 1)
		StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_LineNamedTwice),
			"this dialogue line seems to be named more than once",
			"which is not allowed. It can be anonymous, but otherwise can only have "
			"one name.");

@ Using:

=
<dialogue-line-clause> ::=
	this is the { ... line } |                           ==> { LINE_NAME_DLC, - }
	mentioning ... |                                     ==> { MENTIONING_DLC, - }
	if ... |                                             ==> { IF_DLC, - }
	unless ... |                                         ==> { UNLESS_DLC, - }
	before ... |                                         ==> { BEFORE_DLC, - }
	after ... |                                          ==> { AFTER_DLC, - }
	to ... |                                             ==> { TO_DLC, - }
	now ... |                                            ==> { NOW_DLC, - }
	without speaking |                                   ==> { WITHOUT_SPEAKING_DLC, - }
	ending the story |                                   ==> { ENDING_DLC, - }
	ending the story finally |                           ==> { ENDING_FINALLY_DLC, - }
	ending the story saying { <quoted-text> } |          ==> { ENDING_SAYING_DLC, - }
	ending the story finally |                           ==> { ENDING_FINALLY_DLC, - }
	ending the story finally saying { <quoted-text> } |  ==> { ENDING_FINALLY_SAYING_DLC, - }
	...                                                  ==> { STYLE_DLC, - }

@ =
void DialogueLines::write_dlc(OUTPUT_STREAM, int c) {
	switch(c) {
		case LINE_NAME_DLC:             WRITE("LINE_NAME"); break;
		case IF_DLC:                    WRITE("IF"); break;
		case UNLESS_DLC:                WRITE("UNLESS"); break;
		case BEFORE_DLC:                WRITE("BEFORE"); break;
		case AFTER_DLC:                 WRITE("AFTER"); break;
		case NOW_DLC:                   WRITE("NOW"); break;
		case TO_DLC:                    WRITE("TO"); break;
		case WITHOUT_SPEAKING_DLC:      WRITE("WITHOUT_SPEAKING"); break;
		case ENDING_DLC:                WRITE("ENDING"); break;
		case ENDING_SAYING_DLC:         WRITE("ENDING_SAYING"); break;
		case ENDING_FINALLY_DLC:        WRITE("ENDING_FINALLY"); break;
		case ENDING_FINALLY_SAYING_DLC: WRITE("ENDING_FINALLY_SAYING"); break;
		case STYLE_DLC:                 WRITE("STYLE"); break;
		default:                        WRITE("?"); break;
	}
}

@ Each line produces an instance of the kind |dialogue line|, using the name
given in its clauses if one was.

@<Add the line to the world model@> =
	if (K_dialogue_line == NULL) internal_error("DialogueKit has not created K_dialogue_line");
	wording W = dl->line_name;
	if (Wordings::empty(W)) {
		TEMPORARY_TEXT(faux_name)
		WRITE_TO(faux_name, "line-%d", dl->allocation_id + 1);
		W = Feeds::feed_text(faux_name);
		DISCARD_TEXT(faux_name)
	}
	pcalc_prop *prop = Propositions::Abstract::to_create_something(K_dialogue_line, W);
	Assert::true(prop, CERTAIN_CE);
	dl->as_instance = Instances::latest();

@h Processing lines after pass 1.
It's now a little later, and the following is called to look at each line and
parse its clauses further. By this point, all instances have been created,
and we can therefore parse the speaker name, "mentioning ..." clauses, "to ..."
clauses, and so on. Instances of the "performance style" kind exist now, too,
so we can also deal with style clauses.

=
void DialogueLines::decide_line_mentions(void) {
	dialogue_line *dl;
	LOOP_OVER(dl, dialogue_line) {
		current_sentence = dl->line_at;
		for (parse_node *clause = dl->line_at->down; clause; clause = clause->next) {
			if (Node::is(clause, DIALOGUE_CLAUSE_NT)) {
				wording CW = Node::get_text(clause);
				int c = Annotations::read_int(clause, dialogue_line_clause_ANNOT);
				switch (c) {
					case MENTIONING_DLC: {
						<dialogue-line-clause>(CW);
						wording A = GET_RW(<dialogue-line-clause>, 1);
						<np-articled-list>(A);
						parse_node *AL = <<rp>>;
						DialogueBeats::parse_topic(dl->mentioning, AL, DIALOGUE_LINE_NT);
						break;
					}
					case TO_DLC: {
						<dialogue-line-clause>(CW);
						wording A = GET_RW(<dialogue-line-clause>, 1);
						dl->interlocutor = DialogueLines::parse_interlocutor(A);
						break;
					}
					case WITHOUT_SPEAKING_DLC:
						dl->without_speaking = TRUE;
						break;
					case STYLE_DLC: {
						<dialogue-line-clause>(CW);
						wording A = GET_RW(<dialogue-line-clause>, 1);
						dl->how_performed = PerformanceStyles::parse_style(A);
						break;
					}
				}
			}
		}
		if (dl->narration == FALSE) @<Parse the speaker description@>;
		if (dl->how_performed == NULL) dl->how_performed = PerformanceStyles::default();
	}
}

@<Parse the speaker description@> =
	wording S = dl->speaker_text;
	if (<s-type-expression-uncached>(S)) {
		parse_node *desc = <<rp>>;
		kind *K = Specifications::to_kind(desc);
		if (Kinds::Behaviour::is_object(K)) {
			dl->speaker_description = desc;
		} else {
			LOG("Speaker parsed as $T\n", desc);
			Problems::quote_source(1, current_sentence);
			Problems::quote_wording(2, S);
			Problems::quote_kind(3, K);
			StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_LineSpeakerNonObject));
			Problems::issue_problem_segment(
				"The dialogue line %1 is apparently spoken by '%2', but that "
				"seems to describe %3, not a person or some other object.");
			Problems::issue_problem_end();
		}
	} else {
		Problems::quote_source(1, current_sentence);
		Problems::quote_wording(2, S);
		StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_LineSpeakerUnknown));
		Problems::issue_problem_segment(
			"The dialogue line %1 is apparently spoken by '%2', but that "
			"isn't something I recognise as the name of a thing or person.");
		Problems::issue_problem_end();
	}

@ Note that the interlocutor -- the person addressed "to", if any -- must be
specified exactly, and not simply given a generic description like "somebody".

=
instance *DialogueLines::parse_interlocutor(wording CW) {
	if (<s-type-expression-uncached>(CW)) {
		parse_node *desc = <<rp>>;
		instance *I = Rvalues::to_instance(desc);
		if (I) {
			kind *K = Instances::to_kind(I);
			if (Kinds::Behaviour::is_object(K)) return I;
		}
		kind *K = Specifications::to_kind(desc);
		LOG("Interlocutor parsed as $T\n", desc);
		Problems::quote_source(1, current_sentence);
		Problems::quote_wording(2, CW);
		Problems::quote_kind(3, K);
		StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_LineToNonObject));
		Problems::issue_problem_segment(
			"The dialogue line %1 is apparently spoken to '%2', but that "
			"seems to describe %3, not an object.");
		Problems::issue_problem_end();
		return NULL;
	} else {
		Problems::quote_source(1, current_sentence);
		Problems::quote_wording(2, CW);
		StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_LineToUnknown));
		Problems::issue_problem_segment(
			"The dialogue line %1 is apparently spoken to '%2', but that "
			"isn't something I recognise as the name of a thing or person.");
		Problems::issue_problem_end();
		return NULL;
	}
}

@ So what remains to be done? The unparsed clauses remaining are |IF| and |UNLESS|,
|BEFORE| and |AFTER|, |NOW|, and the various story-ending clauses: but all of those
are essentially code rather than data, and we will parse those in //runtime: Dialogue//.