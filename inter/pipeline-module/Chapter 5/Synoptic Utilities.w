[Synoptic::] Synoptic Utilities.

Utility functions for generating the code in the synoptic module.

@h Dealing with symbols.
We are going to need to read and write these: for reading --

=
inter_symbol *Synoptic::get_symbol(inter_package *pack, text_stream *name) {
	inter_symbol *loc_s =
		InterSymbolsTable::symbol_from_name(InterPackage::scope(pack), name);
	if (loc_s == NULL) Metadata::err("package symbol not found", pack, name);
	return loc_s;
}

inter_tree_node *Synoptic::get_definition(inter_package *pack, text_stream *name) {
	inter_symbol *def_s = InterSymbolsTable::symbol_from_name(InterPackage::scope(pack), name);
	if (def_s == NULL) {
		LOG("Unable to find symbol %S in $6\n", name, pack);
		internal_error("no symbol");
	}
	inter_tree_node *D = def_s->definition;
	if (D == NULL) {
		LOG("Undefined symbol %S in $6\n", name, pack);
		internal_error("undefined symbol");
	}
	return D;
}

@ To clarify: here, the symbol is optional, that is, need not exist; but if it
does exist, it must have a definition, and we return that.

=
inter_tree_node *Synoptic::get_optional_definition(inter_package *pack, text_stream *name) {
	inter_symbol *def_s = InterSymbolsTable::symbol_from_name(InterPackage::scope(pack), name);
	if (def_s == NULL) return NULL;
	inter_tree_node *D = def_s->definition;
	if (D == NULL) internal_error("undefined symbol");
	return D;
}

@ And this creates a new symbol:

=
inter_symbol *Synoptic::new_symbol(inter_package *pack, text_stream *name) {
	return InterSymbolsTable::create_with_unique_name(InterPackage::scope(pack), name);
}

@h Making textual constants.

=
void Synoptic::textual_constant(inter_tree *I, pipeline_step *step,
	inter_symbol *con_s, text_stream *S, inter_bookmark *IBM) {
	SymbolAnnotation::set_b(con_s, TEXT_LITERAL_IANN, TRUE);
	inter_ti ID = InterWarehouse::create_text(InterTree::warehouse(I),
		InterBookmark::package(IBM));
	Str::copy(InterWarehouse::get_text(InterTree::warehouse(I), ID), S);
	Produce::guard(Inter::Constant::new_textual(IBM,
		InterSymbolsTable::id_from_symbol(I, InterBookmark::package(IBM), con_s),
		InterSymbolsTable::id_from_symbol(I, InterBookmark::package(IBM),
			RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)),
		ID, (inter_ti) InterBookmark::baseline(IBM) + 1, NULL));
}

@h Making functions.

=
inter_package *synoptic_fn_package = NULL;
packaging_state synoptic_fn_ps;
void Synoptic::begin_function(inter_tree *I, inter_name *iname) {
	synoptic_fn_package = Produce::function_body(I, &synoptic_fn_ps, iname);
}
void Synoptic::end_function(inter_tree *I, pipeline_step *step, inter_name *iname) {
	Produce::end_function_body(I);
	inter_symbol *fn_s = InterNames::to_symbol(iname);
	Produce::guard(Inter::Constant::new_function(Packaging::at(I),
		InterSymbolsTable::id_from_symbol(I, InterBookmark::package(Packaging::at(I)), fn_s),
		InterSymbolsTable::id_from_symbol(I, InterBookmark::package(Packaging::at(I)),
			RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)),
		synoptic_fn_package,
		Produce::baseline(Packaging::at(I)), NULL));
	Packaging::exit(I, synoptic_fn_ps);
}

@ To give such a function a local:

=
inter_symbol *Synoptic::local(inter_tree *I, text_stream *name, text_stream *comment) {
	return Produce::local(I, K_value, name, INVALID_IANN, comment);
}

@h Making arrays.

=
inter_tree_node *synoptic_array_node = NULL;
packaging_state synoptic_array_ps;

void Synoptic::begin_array(inter_tree *I, pipeline_step *step, inter_name *iname) {
	synoptic_array_ps = Packaging::enter_home_of(iname);
	inter_symbol *con_s = InterNames::to_symbol(iname);
	synoptic_array_node = Inode::new_with_3_data_fields(Packaging::at(I), CONSTANT_IST,
		 InterSymbolsTable::id_from_symbol_at_bookmark(Packaging::at(I), con_s),
		 InterSymbolsTable::id_from_symbol_at_bookmark(Packaging::at(I),
		 	RunningPipelines::get_symbol(step, list_of_unchecked_kind_RPSYM)),
		 CONSTANT_INDIRECT_LIST, NULL, 
		 (inter_ti) InterBookmark::baseline(Packaging::at(I)) + 1);
}

void Synoptic::end_array(inter_tree *I) {
	inter_error_message *E = InterConstruct::verify_construct(
		InterBookmark::package(Packaging::at(I)), synoptic_array_node);
	if (E) {
		Inter::Errors::issue(E);
		internal_error("synoptic array failed verification");
	}
	NodePlacement::move_to_moving_bookmark(synoptic_array_node, Packaging::at(I));
	Packaging::exit(I, synoptic_array_ps);
}

@ Three ways to define an entry:

=
void Synoptic::numeric_entry(inter_ti val2) {
	Inode::extend_instruction_by(synoptic_array_node, 2);
	synoptic_array_node->W.instruction[synoptic_array_node->W.extent-2] = LITERAL_IVAL;
	synoptic_array_node->W.instruction[synoptic_array_node->W.extent-1] = val2;
}
void Synoptic::symbol_entry(inter_symbol *S) {
	Inode::extend_instruction_by(synoptic_array_node, 2);
	inter_package *pack = InterPackage::container(synoptic_array_node);
	inter_symbol *local_S =
		InterSymbolsTable::create_with_unique_name(InterPackage::scope(pack), S->symbol_name);
	Wiring::wire_to(local_S, S);
	inter_ti val1 = 0, val2 = 0;
	Inter::Types::symbol_to_pair(InterPackage::tree(pack), pack, local_S, &val1, &val2);
	synoptic_array_node->W.instruction[synoptic_array_node->W.extent-2] = ALIAS_IVAL;
	synoptic_array_node->W.instruction[synoptic_array_node->W.extent-1] = val2;
}
void Synoptic::textual_entry(text_stream *text) {
	Inode::extend_instruction_by(synoptic_array_node, 2);
	inter_package *pack = InterPackage::container(synoptic_array_node);
	inter_tree *I = InterPackage::tree(pack);
	inter_ti val2 = InterWarehouse::create_text(InterTree::warehouse(I), pack);
	text_stream *glob_storage = InterWarehouse::get_text(InterTree::warehouse(I), val2);
	Str::copy(glob_storage, text);
	synoptic_array_node->W.instruction[synoptic_array_node->W.extent-2] = LITERAL_TEXT_IVAL;
	synoptic_array_node->W.instruction[synoptic_array_node->W.extent-1] = val2;
}