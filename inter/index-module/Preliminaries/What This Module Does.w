What This Module Does.

An overview of the index module's role and abilities.

@h Prerequisites.
The index module is a part of the Inform compiler toolset. It is
presented as a literate program or "web". Before diving in:
(a) It helps to have some experience of reading webs: see //inweb// for more.
(b) The module is written in C, in fact ANSI C99, but this is disguised by the
fact that it uses some extension syntaxes provided by the //inweb// literate
programming tool, making it a dialect of C called InC. See //inweb// for
full details, but essentially: it's C without predeclarations or header files,
and where functions have names like |Tags::add_by_name| rather than just |add_by_name|.
(c) This module uses other modules drawn from the compiler (see //structure//), and also
uses a module of utility functions called //foundation//.
For more, see //foundation: A Brief Guide to Foundation//.

@h The Index.
All users of the Inform GUI app are familiar with the Index: it's a sort of
mini-website giving a detailed picture of the content of the story being
created. In the current design, there are seven colour-coded "pages", each
divided up into two or more parts called "elements".

In fact, this is only one of the possible "index products". It's also possible
to generate an EPS (encapsulated PostScript) file of a spatial map, for example.

Until 2021 the Index for a project was generated by the main //inform7// compiler,
but a radical refactoring then moved the entire //index// module into //inter//
instead. Index products are now generated from trees of Inter code, not from
Inform projects as such:
= (text)
                      source text
                          | 
                          | inform7
                         \|/ 
                      inter tree
                       /     \
               inter  /       \  inter 
    (final module)   /         \   (index module)
                    |           |
                   \|/         \|/
           generated code     Index products
                    |
                    | inform6 (or similar)
                   \|/
       Executable products
=

@ The //index// module has a very simple API: point it at a tree of Inter code,
say what sort of index you want, and go. See //Indexing API// for the details,
though the details are not much more than that.

@h Localisation.
A new and somewhat experimental addition in 2021 is the ability to localise the
Index, that is, to produce an Index in a language other than English. This does
not of course aim to translate source text: simply to translate subheadings, notes,
and other fixed-wording text in the Index.

As a demonstration, try running a project with:
= (text as Inform 7)
Use French language index.
=
You should then find that the index has a French-titled Contents section -- only
a couple of strings have been localised at present, and those not localised
revert to English, so the index still looks basically English. This is all really
just laying groundwork.

For how to write localisation files, see //html: Localisation//, or follow
the example of |inform/inform7/Internal/Languages/English/Index.txt|.
