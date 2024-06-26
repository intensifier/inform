[BlorbErrors::] Blorb Errors.

To spool error messages into the HTML report.

@ Foundation has a perfectly good library of code for error messages, but
we won't use it, because we need to do something unusual with them: they
must not only be printed to standard error, but also spooled into HTML
format for possible use on a status HTML page. Hence this section.

Inblorb is in any case only minimally helpful when diagnosing problems,
because it's intended to be used as the back end of a system which only
generates correct blurb files, so that everything will work -- ideally, the
Inform user will never know that Inblorb exists.

First, the current position of errors is recorded so that we can report
the source of the trouble:

=
text_file_position *error_position = NULL;
void BlorbErrors::set_error_position(text_file_position *tfp) {
	error_position = tfp;
}

void BlorbErrors::describe_file_position(OUTPUT_STREAM) {
	if (error_position) {
		WRITE("%f, line %d: ",
			error_position->text_file_filename,
			error_position->line_count);
	}
}

@ Fatalities:

=
void BlorbErrors::fatal(char *erm) {
	TEMPORARY_TEXT(ERM)
 	BlorbErrors::describe_file_position(ERM);
	WRITE_TO(ERM, "Fatal error: %s\n", erm);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
    Main::print_report();
    exit(1);
}

void BlorbErrors::fatal_fs(char *erm, filename *fn) {
	TEMPORARY_TEXT(ERM)
 	BlorbErrors::describe_file_position(ERM);
	WRITE_TO(ERM, "Fatal error: %s: filename '%f'\n", erm, fn);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
    Main::print_report();
    exit(1);
}

@ Mere indispositions:

=
void BlorbErrors::error(char *erm) {
	TEMPORARY_TEXT(ERM)
 	BlorbErrors::describe_file_position(ERM);
	WRITE_TO(ERM, "Error: %s\n", erm);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
}

void BlorbErrors::error_1(char *erm, char *s) {
	TEMPORARY_TEXT(ERM)
 	BlorbErrors::describe_file_position(ERM);
	WRITE_TO(ERM, "Error: %s: '%s'\n", erm, s);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
}

void BlorbErrors::error_1S(char *erm, text_stream *s) {
	TEMPORARY_TEXT(ERM)
 	BlorbErrors::describe_file_position(ERM);
	WRITE_TO(ERM, "Error: %s: '%S'\n", erm, s);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
}

void BlorbErrors::error_1f(char *erm, filename *F) {
	TEMPORARY_TEXT(ERM)
 	BlorbErrors::describe_file_position(ERM);
	WRITE_TO(ERM, "Error: %s: '%f'\n", erm, F);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
}

void BlorbErrors::errorf_1S(char *erm, text_stream *s1) {
	TEMPORARY_TEXT(ERM)
 	WRITE_TO(ERM, erm, s1);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
}

void BlorbErrors::errorf_2S(char *erm, text_stream *s1, text_stream *s2) {
	TEMPORARY_TEXT(ERM)
 	WRITE_TO(ERM, erm, s1, s2);
	BlorbErrors::spool_error(ERM);
	DISCARD_TEXT(ERM)
}

@ As noted, errors are spooled to a placeholder variable, for the benefit of
the report:

=
void BlorbErrors::spool_error(OUTPUT_STREAM) {
	Placeholders::append_to(I"CBLORBERRORS", I"<li>");
	Placeholders::append_to(I"CBLORBERRORS", OUT);
	Placeholders::append_to(I"CBLORBERRORS", I"</li>");
	STREAM_COPY(STDERR, OUT);
	error_count++;
}
