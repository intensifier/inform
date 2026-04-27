# Pending

These will be added to release notes when the release is made. This page
only holds bug fixes and other minor tweaks: anything larger is covered by
[Inform evolution](https://github.com/ganelson/inform-evolution) proposals.

## Featurettes arising from bug reports, but too small for Inform Evolution proposals

- External files are now stored as UTF-8 encoded Unicode, rather than ISO Latin-1,
	extending the range of characters they can store, and meaning that they can
	hold anything Inform stories can print. See [PR#192](https://github.com/ganelson/inform/pull/192).

- This was reported as Jira bug [I7-2087](https://inform7.atlassian.net/browse/I7-2087)
	"three anonymous standard rules", but is arguably a feature request: that three
	rules in the Standard Rules should have names. All three are simple rules, two
	of them occurring early and late in the turn cycle to consider whether a scene
	change has happened, and one as the fallback rule making an action succeed if
	no rules have intervened in the process.
	```
	early scene changing stage
	late scene changing stage
	default action success rule
	```

- Similarly: see Jira bug [I7-2556](https://inform7.atlassian.net/browse/I7-2556)
	```
	very likely to mean taking off what's currently worn rule
	```

- In past builds it caused some surprise that `[regarding...]` did not affect
	`[s]`, the text substitution which adds an "s" if the last thing(s) discussed
	are plurally named. This was reported as [I7-2605](https://inform7.atlassian.net/browse/I7-2605).
	That behaviour was correct as documented, but rather than dismiss the bug report
	it seemed more helpful to implement this implied feature request. So:
	```
	"the [regarding the number of animals in the crate]animal[s] in the crate"
	```
	now prints "animals", plural, if the number is 0 or at least 2, and "animal", singular,
	if there's just one in the crate.

- Three previously unindexed phrases used by the Standard Rules but not documented
    have now been brought out into the open: `yes` and `no` as aliases for
    `decide yes` and `decide no` in the body of phrases to decide if some
    condition holds; and `if substituting text for comparison purposes`, which
    was previously called `if expanding text for comparison purposes`, but has
    been renamed for consistency with the existing `substituted form of` phrase,
    to which it's related. This condition is true when text is being printed
    (so that various activities to do with, say, printing names will fire), but
    only internally in order to make a comparison between texts, and not on
    screen. That can be useful to avoid side-effects happening when they
    shouldn't: see for example the `make named things mentioned rule` in the
    Standard Rules, which is the only place it uses this phrase.

- The humble business of printing the "banner" for a story, that is, text like:
	```
	Dreams of the Occident
	An Interactive Fiction
	Release 3 / Serial Number 260415 / Inform 7 v10.2.0
	```
	has been reimplemented in Inform source text. In particular, the new
	```
	standard printing the banner text rule
	```
	is the default arrangement: lines 1 to 3 above are responses `(A)` to `(C)`
	for this rule. See Jira bug
	[I7-2686](https://inform7.atlassian.net/browse/I7-2686).

- Correspondingly, the `announce the story file version rule`, which provides
	the default implementation of the `VERSION` command, has been rewritten as
	Inform source text, and its output is slightly tidier:
	```
	>VERSION
	Dreams of the Occident
	An Interactive Fiction
	Release 3 / Serial Number 260415 / Inform 7 v10.2.0+6X96
	Identification number: A7A885DC-1187-4D85-9550-F2DC02B2BD90
	Interpreter version 0.6.0 / VM 3.1.3

	There are no copyright acknowledgements for extensions used by this story.
	```
	Note that that last sentence, the output from `COPYRIGHT` in this case,
	is the new response `(A)` of the `announce the copyright licences rule`;
	it is printed if every extension compiled into the story has `Use authorial modesty`
	specified, so that the author is waiving the credit.

- The above was handled with four new bibliographic variables, which are read-only:
	```
	story serial code
	project IFID
	Inform version number
	Inform build code
	```

- There is a new use option
	```
	Use project IFID of "...".
	```
	which sets the IFID. If the project already has a `uuid.txt` file, then the
	Use option value takes precedence over that, but a warning is issued
	(unless the `uuid.txt` sets the same IFID, tested case insensitively, or
	the `uuid.txt` file sets the IFID `00000000-0000-0000-0000-000000000000`,
	a special value reserved for testing). See Jira bug
	[I7-2629](https://inform7.atlassian.net/browse/I7-2629).

- Two new bibliographic variables now exist: `story serial code` and `project IFID`.
	These are read-only, and are automatically set by Inform at compile time.
	```
	say "Hmm, the bar code in the lining of my jacket reads [project IFID].";
	```

- When releasing a story with a website, and a cover image which has alt-text
	provided, that text is now used on the thumbnail cover images in the website.
	(See Jira bug [I7-2615](https://inform7.atlassian.net/browse/I7-2615): the
	lack of this feature could very fairly have been called a bug.)

- Inform 6.45 (included with this release of I7) clarified the language design
	to say that a braced code block can appear wherever a statement can, as in
	most C-like languages. This is a convenience when tangling code to I6 from
	a literate web, and in particular enables kit sources to make use of
	named holons. The I6 parser inside I7, used for `(- ... -)` inclusions and
	when compiling kits to Inter code, has been updated to allow these braces.

- Errors occurring in I6-syntax code, either in `(- ... -)` inclusions into I7
	source text or in kit source code, are now reported more fully, with source
	references and links provided. (A feature request for this was filed as
	Jira bug [I7-2232](https://inform7.atlassian.net/browse/I7-2232).)

- The obscure debugging verb TREE has been renamed SHOWTREE to reduce the risk
	of confusion when "tree" is typed in reply to a clarifying question from the
	command parser, in a debug build (such as in the app). See
	Jira bug [I7-2398](https://inform7.atlassian.net/browse/I7-2398). Its output
	has also been modernised so that it gives a clearer picture of the model
	world, and in particular, covers incorporation. See  See Jira bug
	[I7-2424](https://inform7.atlassian.net/browse/I7-2424).

- The transcript file is, in Glulx, now written as UTF-8 text. See
	Jira bug [I7-2516](https://inform7.atlassian.net/browse/I7-2516).

- The Inform 6 compiler's built-in pseudofunction "random()" can now be replaced. See
	Jira bug [I7-2435](https://inform7.atlassian.net/browse/I7-2435).

- Inform 7 now optimises compilation so that code to parse command text for kinds
	is only generated if command grammar involving those kinds actually exists.
	This makes little difference to eventual code size because the Inform 6
	compiler would have removed those functions anyway, but it does reduce
	dictionary word usage. Typically, it means about 120 words fewer in the
	story file dictionary: only a trivial memory saving, but it avoids some
	warnings due to dictionary entry clashes. See Jira bug (really a suggestion)
	[I7-2573](https://inform7.atlassian.net/browse/I7-2573).

## Performance improvements

The most demanding code generated by Inform is in text-handling, where complex
string operations, especially if repeated or carried out on a large scale, incur
a time overhead because of the need for memory allocation and deallocation. This
has been optimised somewhat on Glulx, so that text literals are quicker to access,
and many text operations run a little faster. In some intensive test cases, this
produces a roughly 30% speed improvement.

## Gender neutrality

"Writing with Inform" and "The Recipe Book" benefit from a revision throughout to
remove unnecessary gender-binary language, mostly to do with pronouns attached
to "the player", or similar. The example `Blue or Pink` has become `Good or Evil`,
and now poses a moral rather than gender-based question.

The little-used rule:

	player aware of his own actions rule

has been renamed:

	player aware of their own actions rule

## Phase-out of (+ ... +)

Since the earliest days of Inform 7, the notation `(+` ... `+)` has needed to
be used, at least occasionally, inside Inform 6-syntax matter in order to refer
back to things which could only be described with source text. So, where `(-` ... `-)`
allowed source text to drop down into C-like code in Inform 6 syntax, `(+` ... `+)`
within that C-level code allowed a climb back up into natural language.

This was always troublesome, and for some years _Writing with Inform_ has warned
that it should be used only as a last resort, and that it would some day likely
be phased out. That has turned out to be true, and this is that day.

Use of `(+` ... `+)` continues to work, but generates a warning message, which
provides a documentation link to the new facilities which replace it. In the
next major release, any use of `(+` ... `+)` will throw a problem message,
not a warning.

## Language kit changes to article-handling

A low-level change to Inform's system for printing in natural languages at
runtime will affect anybody translating Inform to write stories in languages
other than English, so we're flagging it up here. It was always an anomaly
that the `LanguageArticles` array (defined in `EnglishLanguageKit`, but other
language kits would have to define it too) had slots for the capitalised
definite, uncapitalised definite, and uncapitalised indefinite articles —
but not the capitalised indefinite, which Inform instead attempted to
synthesize by printing to an array and then capitalising the first word. That
worked most of the time, but caused problems with rules written for the
`printing the name of` activity, which was being called twice over. This has
long been a nuisance, as the existence of extensions like `Indefinite Article Substitution Fix`
by Matt Weiner and `Print Stage Detection` by Taryn Michelle go to show.

`LanguageArticles` now has a slot for capitalised indefinite articles, and
this is all more consistent. See Jira bug [I7-2138](https://inform7.atlassian.net/browse/I7-2138)
for more on why we've done this, and see [PR#190](https://github.com/ganelson/inform/pull/190)
for more on how.

## Version updates

The Inform repository (and thus its released app) includes a few resources by
external developers, which are periodically updated. In this release:

- The Quixe web-based interpreter has been updated to version 2.2.6.
- The embedded copy of Inform 6 has been updated to an unstable version 6.45,
	and we expect this to be replaced by release 6.45 when the latter is ready.

## Bug fixes

- Fix for Jira bug [I7-2696](https://inform7.atlassian.net/browse/I7-2696)
	"inblorb error with `release along with a "parchment" interpreter` with lower-case `p`"
- Fix for Jira bug [I7-2692](https://inform7.atlassian.net/browse/I7-2692)
	"K1_room doesn't have action_bitmap"
- Fix for Jira bug [I7-2676](https://inform7.atlassian.net/browse/I7-2676)
	"Extended kit-defined enumerated kinds assigns the same value twice"
- Fix for Jira bug [I7-2673](https://inform7.atlassian.net/browse/I7-2673)
	"External files owned by other projects headers rewritten by current UUID"
- Fix for Jira bug [I7-2665](https://inform7.atlassian.net/browse/I7-2665)
	"Compilation error when an `Index map with` assertions refers to `level`"
- Fix for Jira bug [I7-2657](https://inform7.atlassian.net/browse/I7-2657)
	"Web release encodes naked ULX instead of blorb"
- Fix for Jira bug [I7-2635](https://inform7.atlassian.net/browse/I7-2635)
	"Error messages about nothing having properties are contradictory"
- Fix for Jira bug [I7-2625](https://inform7.atlassian.net/browse/I7-2625)
	"`use unabbreviated object names` isn't working"
- Fix for Jira bug [I7-2619](https://inform7.atlassian.net/browse/I7-2619)
	"Upon `resume the story` in a Final Question rule, `when play ends` rules are followed again before resumption"
- Fix for Jira bug [I7-2608](https://inform7.atlassian.net/browse/I7-2608)
	"Equations `given by x =` in Basic Inform breaks the use of x as an identifier in other contexts"
- Fix for Jira bug [I7-2603](https://inform7.atlassian.net/browse/I7-2603)
	"`window` in object names conflicting with `glk window`", and its duplicate
	[I7-2649](https://inform7.atlassian.net/browse/I7-2649)
- Fix for Jira bug [I7-2601](https://inform7.atlassian.net/browse/I7-2601)
	"Add a new field to `rights` in `extension_metadata.json` to signal that a license needs no acknowledgement"
- Fix for Jira bug [I7-2568](https://inform7.atlassian.net/browse/I7-2568)
	"Setting numeric EPS map parameters causes parts of the EPS map to vanish"
- Fix for Jira bug [I7-2589](https://inform7.atlassian.net/browse/I7-2589)
	"Abject failure when giving another name to an `at the time when` rule"
- Fix for Jira bug [I7-2551](https://inform7.atlassian.net/browse/I7-2551)
	"The parser nothing error internal rule response (C) is badly worded"
	([commit 9175435](https://github.com/ganelson/inform/commit/9175435a7a45acd1257812871bc1068818d65573))
- Fix for Jira bug [I7-2540](https://inform7.atlassian.net/browse/I7-2540)
	"Clicking the unlist rule button gives the rule response text statement instead of the unlist rule statement"
	([commit 33e44aa](https://github.com/ganelson/inform/commit/33e44aa47876ae110a69b0de12618516dedb3e24))
- Fix for Jira bug [I7-2543](https://inform7.atlassian.net/browse/I7-2543)
	"Out-of-bounds memory access with one text to various K relations"
	([commit 693da60](https://github.com/ganelson/inform/commit/693da60d8f734d62b0c7e9c04c34d5e814f9f613))	
- Fix for Jira bug [I7-2542](https://inform7.atlassian.net/browse/I7-2542)
	"Serious run-time problem with inclusion of `if (condition), (phrase)` statement in code blocks formatted with `begin; ... end if;`"
- Fix for Jira bug [I7-2532](https://inform7.atlassian.net/browse/I7-2532)
	"Can't refer to the the text of the announce items from multiple object lists rule response (A) in the normal way"
	([commit d47d1bb](https://github.com/ganelson/inform/commit/d47d1bb801090ed6d4a60c27b8111e6cdcdabc7e))
- Fix for Jira bug [I7-2530](https://inform7.atlassian.net/browse/I7-2530)
	"Runtime error when consulting it about with missing topic (first time only)"
	([commit d9547d7](https://github.com/ganelson/inform/commit/d9547d71329c4af07de7e000ad1e6a6a825d4ff0))
- Fix for Jira bug [I7-2518](https://inform7.atlassian.net/browse/I7-2518)
	"Doesn't correctly autoassign values for kit defined kinds"
	([commit 5136eaa](https://github.com/ganelson/inform/commit/5136eaad3366efaf99e0f73da0916deee80bb216))
- Fix for Jira bug [I7-2510](https://inform7.atlassian.net/browse/I7-2510)
	"Arguments leaking between phrases (?) depending on wording"
	([commit 4e3c5f8](https://github.com/ganelson/inform/commit/4e3c5f8f0606201da56fd7f1f49e835c593c3a84))
- Fix for Jira bug [I7-2492](https://inform7.atlassian.net/browse/I7-2492)
	"Numbers in template code are truncated to 32 bits without warning"
	([commit 26c0928](https://github.com/ganelson/inform/commit/26c0928ea24a4786f980b99f900d2fbbf9324a21))
- Fix for Jira bug [I7-2490](https://inform7.atlassian.net/browse/I7-2490)
	"Numbers in template code are truncated to 32 bits without warning"
	([commit 752e0ea](https://github.com/ganelson/inform/commit/752e0eacf84476dd2f121980291414ac4839ca86))
- Fix for Jira bug [I7-2484](https://inform7.atlassian.net/browse/I7-2484)
	"The meaning of the verb 'are suspicious of' causes abject failure"
	([commit 2dd4dcb](https://github.com/ganelson/inform/commit/2dd4dcb25ea57191b80fe8c590491f2bba7bfc18))	
- Fix for Jira bug [I7-2470](https://inform7.atlassian.net/browse/I7-2470)
	"Removing an entry from a list of text in a deciding phrase corrupts the original list"
	([commit 570d703](https://github.com/ganelson/inform/commit/570d703a8c78d628f883d1ab6559b64cdbc730d3))
- Fix for Jira bug [I7-2460](https://inform7.atlassian.net/browse/I7-2460)
	"Standard 'deciding whether all include' rules don't apply to an actor."
	([PR#138](https://github.com/ganelson/inform/pull/138))
- Fix for Jira bug [I7-2458](https://inform7.atlassian.net/browse/I7-2458)
	"The uuid.txt file should be whitespace-stripped before use"
	(see [Inweb commit 4557cc1](https://github.com/ganelson/inform/commit/4557cc1925aebd7f1d075ea458b76f6970df3d57))
- Fix for Jira bug [I7-2440](https://inform7.atlassian.net/browse/I7-2440)
	"Returning a list of text and then removing from it makes everything explode"
	([commit 570d703](https://github.com/ganelson/inform/commit/570d703a8c78d628f883d1ab6559b64cdbc730d3))
- Fix for Jira bug [I7-2420](https://inform7.atlassian.net/browse/I7-2420)
	"Extension author name casing can cause `for use with` in another extension's section header to go awry"
	([commit bf011bc](https://github.com/ganelson/inform/commit/bf011bc8e69dcfd274718a46d329c7eb3ab02f96))
- Fix for Jira bug [I7-2416](https://inform7.atlassian.net/browse/I7-2416)
	"Hyperbolic sinh and cosh each have the implementation the other needs"
	([PR#126](https://github.com/ganelson/inform/pull/126))
- Fix for Jira bug [I7-2407](https://inform7.atlassian.net/browse/I7-2407)
	"Abject failure when trying to add an intermediate kind"
	([commit 1a963d3](https://github.com/ganelson/inform/commit/1a963d32b39488eb0b7e1ff36ba74cd6ec1f9e68))
- Fix for Jira bug [I7-2399](https://inform7.atlassian.net/browse/I7-2399)
	"Bad error message with long action names sharing same beginning text"
	(see [Inweb commit db36ef3](https://github.com/ganelson/inform/commit/db36ef30c9dfbcd956a7c7d44ef1094f710b4d6d))
- Fix for Jira bug [I7-2384](https://inform7.atlassian.net/browse/I7-2384)
	"Some Standard Rule responses use 'here' instead of '[here]', producing 'here' in cases that should be 'there'"
	([PR#116](https://github.com/ganelson/inform/pull/116))
- Fix for Jira bug [I7-2382](https://inform7.atlassian.net/browse/I7-2382)
	"creating a specific number of things causing P49: Memory allocation proved impossible on Z-machine"
- Fix for Jira bug [I7-2376](https://inform7.atlassian.net/browse/I7-2376)
	"Incorrect behavior for 'empty' adjective applied to 1-to-1 relations"
	(see [commit 918f9c3](https://github.com/ganelson/inform/commit/918f9c37193ea4aa09a21e34c622233fe4cc69db))
- Fix for Jira bug [I7-2370](https://inform7.atlassian.net/browse/I7-2370)
	"A template file ending with a comment and no line break breaks the next file"
	(see [Inweb commit 901d125](https://github.com/ganelson/inform/commit/901d12582f1d7746046f11ecac6c2f357ddfac81))
- Fix for Jira bug [I7-2366](https://inform7.atlassian.net/browse/I7-2366)
	"10.1 segfaults with compound units that haven't been explicitly defined"
	([commit ad2c648](https://github.com/ganelson/inform/commit/ad2c648098279dec88c654b23e633037874bc8d3))
- Fix for Jira bug [I7-2359](https://inform7.atlassian.net/browse/I7-2359)
	"compiler accepts I6 with imbalanced braces (`{}`)"
- Fix for Jira bug [I7-2356](https://inform7.atlassian.net/browse/I7-2356)
	"If an after rule fails, the action `fails` despite having been carried out"
	(see [PR#197](https://github.com/ganelson/inform/pull/197))
- Fix for Jira bug [I7-2355](https://inform7.atlassian.net/browse/I7-2355)
	to do with how to handle symlinks or broken directory entries
	(see [Inweb PR#28](https://github.com/ganelson/inweb/pull/28))
- Fix for Jira bug [I7-2353](https://inform7.atlassian.net/browse/I7-2353)
	"Setting room description heading rule response (A) causes Array index out of bounds"
	([commit 6778a15](https://github.com/ganelson/inform/commit/6778a15ff6004e4dc8760975851fb478b0eef419))
- Fix for Jira bug [I7-2351](https://inform7.atlassian.net/browse/I7-2351)
	"Properties not being set when creating objects by table"
	([commit e6b21df](https://github.com/ganelson/inform/commit/e6b21df18f4c28e7d71a8526def8c8bddb54fd56))
- Fix for Jira bug [I7-2349](https://inform7.atlassian.net/browse/I7-2349)
	"example 399, "Solitude", has a bug"
	([PR#115](https://github.com/ganelson/inform/pull/115))
- Fix for Jira bug [I7-2344](https://inform7.atlassian.net/browse/I7-2344)
	"inform7's -silence flag should imply -no-progress"
	([commit 687dba6](https://github.com/ganelson/inform/commit/687dba6857983420a76559cfed292cde0a2891fb))
- Fix for Jira bug [I7-2341](https://inform7.atlassian.net/browse/I7-2341)
	"You can `use dict_word_size of 12` and I7's ok with it, but then passes it
	on to I6 in lower case"
	([commit a011ec6](https://github.com/ganelson/inform/commit/a011ec67b900bf13d89ab73a46dc519b58c69906))
- Fix for Jira bug [I7-2336](https://inform7.atlassian.net/browse/I7-2336)
	"When an either-or property is implemented as an I6 property rather than an I6 attribute, reading the property throws a run-time error"
	([commit 44a87dd](https://github.com/ganelson/inform/commit/44a87dd54d6465ae605a0e9974e50582c34524d3))
- Fix for Jira bug [I7-2335](https://inform7.atlassian.net/browse/I7-2335)
	"Several previously-legal forms of the Array directive no longer work in I6 inclusions in 10.1.2"
	([commit 4d97b49](https://github.com/ganelson/inform/commit/4d97b499cfd3e15650d1bba1e6e8c70c24a01fb2))
- Fix for Jira bug [I7-2334](https://inform7.atlassian.net/browse/I7-2334)
	"imbalanced parentheses in Definition by I6 Condition causes abject failure"
	([commit 5d45863](https://github.com/ganelson/inform/commit/5d4586387c6b7405cd45e43f04c984583cd76bb3))
- Fix for Jira bug [I7-2328](https://inform7.atlassian.net/browse/I7-2328)
	"Compiler hard-codes bad/deprecated Glulx acceleration instructions"
	([commit a2c1274](https://github.com/ganelson/inform/commit/a2c1274a39d87abe6da9fa7cae9dd8e7dc566ea6))
- Fix for Jira bug [I7-2329](https://inform7.atlassian.net/browse/I7-2329)
	"Colons in story title are not sanitised in release filenames"
	([commit f50a043](https://github.com/ganelson/inform/commit/f50a043fabf558ad3396bc1b97dfb13b93619305))
- Fix for Jira bug [I7-2317](https://inform7.atlassian.net/browse/I7-2317) and
	duplicate [I7-2368](https://inform7.atlassian.net/browse/I7-2368)
	"A phrase passed as a parameter to a 'To phrase' in the form 'now <condition>' is compiled as a condition, not an assertion"
	([commit 0c0e099](https://github.com/ganelson/inform/commit/0c0e099171d4bc713c426fec31101662ca699720))
- Fix for Jira bugs [I7-2310](https://inform7.atlassian.net/browse/I7-2310),
	[I7-2333](https://inform7.atlassian.net/browse/I7-2333),
	[I7-2364](https://inform7.atlassian.net/browse/I7-2364), all duplicates
	to do with actions defined with "it" in the name
- Fix for Jira bug [I7-2308](https://inform7.atlassian.net/browse/I7-2308)
	"If you define a verb to mean a block-valued property, setting via verb works, but testing via verb is always false"
	([commit d911182](https://github.com/ganelson/inform/commit/d911182b36e308dde5b7827ac3cac367c178831e))
- Fix for Jira bug [I7-2306](https://inform7.atlassian.net/browse/I7-2306)
	"remaining arbitary ifdefs in kit code": also fixes an unreported bug in
	which the use options "Use numbered rules", "Use manual pronouns",
	"Use fast route-finding" and "Use slow route-finding" had ceased to have
	any effect; all taken care of in the implementation of IE-0018
	([commit 95e613c](https://github.com/ganelson/inform/commit/95e613cd6a2d4341823f16f1635e59136710090a))
	(see also duplicate report [I7-2276](https://inform7.atlassian.net/browse/I7-2276))
- Fix for Jira bug [I7-2304](https://inform7.atlassian.net/browse/I7-2304)
	"switch(): first branch can't start with negative number"
	([commit 1c18007](https://github.com/ganelson/inform/commit/1c18007326bf6fb15c74a1d5742827a4d76a0c20))
- Fix for Jira bug [I7-2301](https://inform7.atlassian.net/browse/I7-2301)
	"compiler error when creating an object with 'there is' and setting conditions or either/or properties"
	([commit dc283f9](https://github.com/ganelson/inform/commit/dc283f9549b3eda25f1a24d09cbf9e5ae59e0b61))
- Fix for Jira bug [I7-2298](https://inform7.atlassian.net/browse/I7-2298)
	""to" in I6 switch statement is not recognized"
	([commit 04e526f](https://github.com/ganelson/inform/commit/04e526f0a676b89fa032d6c886a146499d5e7ae5))
- Fix for Jira bug [I7-2297](https://inform7.atlassian.net/browse/I7-2297)
	"Missing semicolon after I6 routine crashed compiler without explanation"
	([commit 4fb6e57](https://github.com/ganelson/inform/commit/4fb6e57b866eacd84d27e4752c7d0147fc982ac0))
- Fix for Jira bug [I7-2287](https://inform7.atlassian.net/browse/I7-2287)
	"Replacing character(s) in a text that is part of a text substitution
	within a property causes interpreters to hang before that property is
	displayed when total length to be displayed is >1026 characters"
- Fix for Jira bug [I7-2284](https://inform7.atlassian.net/browse/I7-2284)
	"Inter error" - arising from a sentence trying to use an either-or property
	in a way which would make it unheld by default, when an existing sentence
	already makes it held by default
	([commit 1fc5055](https://github.com/ganelson/inform/commit/1fc505507b52be19a09cc3898326952954620312))
- Fix for Jira bug [I7-2282](https://inform7.atlassian.net/browse/I7-2282)
	"segfaults in linux with latest inform, ..., built with gcc": see
	also [I7-2108](https://inform7.atlassian.net/browse/I7-2108)
	(hat-tip to Adrian Welcker: [PR#111](https://github.com/ganelson/inform/pull/111))
- Fix for Jira bug [I7-2278](https://inform7.atlassian.net/browse/I7-2278)
	"Object or subkind of object with anonymous properties causing compilation failure"
	([commit aaf0aa9](https://github.com/ganelson/inform/commit/aaf0aa9ca0f0b589d63f0d07b123ccecb35049de))	
- Fix for Jira bug [I7-2275](https://inform7.atlassian.net/browse/I7-2275)
	"Bad results from 'K that relates to Y (a value of kind L) by R' when K is a subkind of what R was defined with"
	([commit 2cca448](https://github.com/ganelson/inform/commit/2cca448105dc5cfa2e4117f724b3905a6e1fc82c))	
- Fix for Jira bug [I7-2269](https://inform7.atlassian.net/browse/I7-2269)
	"Output of I6 floating point literals strips the '+', resulting in uncompilable I6"
	([commit 46349cb](https://github.com/ganelson/inform/commit/46349cb85c56116602c9245ee47e67ea08155d40))
- Fix for Jira bug [I7-2267](https://inform7.atlassian.net/browse/I7-2267)
	"I6 inclusion for which compiler hangs (using '::' operator)"
	([commit f46433c](https://github.com/ganelson/inform/commit/f46433c22cfd9d414b7c337f8ee58220fb9286cc))
- Fix for Jira bug [I7-2265](https://inform7.atlassian.net/browse/I7-2265)
	"Compiler fails on creating an instance of a specified kind with multiple parts"
	([commit af2531f](https://github.com/ganelson/inform/commit/af2531f4b2b4d1f59e4a9b45a8ddc274c94c7f77))
- Fix for Jira bug [I7-2264](https://inform7.atlassian.net/browse/I7-2264)
	"Cannot compile 'Verb meta' directive inside a kit"
	([commit cbe7012](https://github.com/ganelson/inform/commit/cbe7012fb6950932ebf2a4b9290f80bcd5970ad1)):
	actually a linker issue if multiple kits do this
- Fix for Jira bug [I7-2255](https://inform7.atlassian.net/browse/I7-2255)
	"Localization detail in Banner routine (uses preposition 'by' in English)"
	([commit ce2b7ba](https://github.com/ganelson/inform/commit/ce2b7ba15b0431caf295316ee6c9fa4843c7251f)): the English word
	`by` had been hard-wired, but is now printed using `BY__WD` instead, which
	in English is declared as `'by'` but in Spanish could be `'por'`, or in
	French `'par'`, for example
- Fix for Jira bug [I7-2247](https://inform7.atlassian.net/browse/I7-2247)
	"Internal error 'unowned' when using 'Understand'"
	([commit 3ebcac0](https://github.com/ganelson/inform/commit/3ebcac0b5dc58e9754de6b2c8dd85fad719e4629))
- Fix for Jira bug [I7-2245](https://inform7.atlassian.net/browse/I7-2245)
	"Internal error when changing a value in a table based on a correspondence"
	([commit 32c4366](https://github.com/ganelson/inform/commit/32c43662084d0c7cbf5edc5f1d62c2fb20cf174e))
- Fix for Jira bug [I7-2242](https://inform7.atlassian.net/browse/I7-2242)
	"Creating kinds via tables fails"
	([commit 0038a2e](https://github.com/ganelson/inform/commit/0038a2e46f91fa104f65c7c910ff7097f1c09198))
- Fix for Jira bug [I7-2241](https://inform7.atlassian.net/browse/I7-2241)
	"Error using a rulebook as one of the kinds of value in a relation"
	([commit bb3fe3a](https://github.com/ganelson/inform/commit/bb3fe3aae2a3a8fb53b4deecd102f4766289ae50))
- Fix for Jira bug [I7-2239](https://inform7.atlassian.net/browse/I7-2239)
	"Can't use a nothing-based rulebook as a parameter"
	([commit b525fba](https://github.com/ganelson/inform/commit/b525fbaf50f866312de34103c6cda16a4f2bd8c9))
- Fix for Jira bug [I7-2237](https://inform7.atlassian.net/browse/I7-2237)
	"Inform hangs when reading a Neptune file in a kit with no final newline"
	([commit 1cd75d8](https://github.com/ganelson/inform/commit/1cd75d8a4946ba10636a8ec474aded9716fffe9b))
- Fix for Jira bug [I7-2235](https://inform7.atlassian.net/browse/I7-2235)
	"List of action names ending with 23 bonus instances of waiting (i.e., action name 0)"
	([commit b5c35fb](https://github.com/ganelson/inform/commit/b5c35fb98e6603d2f49c95e8031189a7dda1f0c8)): in fact those were
	anonymous debugging actions from WorldModelKit, which are valid instances of
	`action name` (and need to be for type safety reasons), but which were not
	properly looped through or described. They now print as, e.g.,
	`performing kit action ##ShowRelations`. As a fringe benefit, of sorts, such
	actions now appear in the logging output of the ACTIONS command (except for
	the actions needed to switch ACTIONS on and off, which are deliberately
	excluded from this since they only add confusion to the story transcript).
- Fix for Jira bug [I7-2234](https://inform7.atlassian.net/browse/I7-2234)
	"Non-heading @ sections not supported in template files"
	(Inweb: [commit f2aaa32](https://github.com/ganelson/inweb/commit/f2aaa32479e14187679828e3e5696f5951b43b38))
- Fix for Jira bug [I7-2230](https://inform7.atlassian.net/browse/I7-2230)
	"When specifying an irregular verb, present participle is based on the verb identifier, not contents of irregular spec"
- Fix for Jira bug [I7-2227](https://inform7.atlassian.net/browse/I7-2227)
	"Backdrop placement assertions being ignored"
	(Inweb: [commit 4943a61](https://github.com/ganelson/inweb/commit/4943a6157c18810b2de949c0bd0d79c81d136fe3))
- Fix for Jira bug [I7-2225](https://inform7.atlassian.net/browse/I7-2225)
	"Translating kinds into I6 doesn't work"
	(Inweb: [commit d608388](https://github.com/ganelson/inweb/commit/d608388d643a85d1aa3c88cfa1710b848bd5cb7e))
- Fix for Jira bug [I7-2213](https://inform7.atlassian.net/browse/I7-2213)
	"I7 expansions such as (+ I7-property-name +) expand to the originally-allocated I6 name, not a translated one"
- Fix for Jira bug [I7-2199](https://inform7.atlassian.net/browse/I7-2199)
	"Property names whose identifiers begin with identical long strings -> Property given twice in the same declaration error"
	([commit 2ac854e](https://github.com/ganelson/inform/commit/2ac854e163a779c0322ecf0736877916653fc40a))
- Fix for Jira bug [I7-2151](https://inform7.atlassian.net/browse/I7-2151)
	"`The <property> of it` following the creation of something creates a thing named it"
- Fix for Jira bug [I7-2142](https://inform7.atlassian.net/browse/I7-2142)
	"With 'the foo rule substitutes for the bar rule when...', the bar rule is
	suppressed but the foo rule isn't followed."
	([commit 11e1f75](https://github.com/ganelson/inform/commit/11e1f756c16aa17b31afd02ca2bb5f4e5abd3ac6))
- Fix for Jira bug [I7-2139](https://inform7.atlassian.net/browse/I7-2139)
	"Articles become part of relation name"
	([commit 85110a9](https://github.com/ganelson/inform/commit/85110a981a3d2419b3778eb383408de122c301a8))
- Fix for Jira bug [I7-2138](https://inform7.atlassian.net/browse/I7-2138)
	to do with capitalised indefinite articles: see notes above.
- Fix for Jira bug [I7-2129](https://inform7.atlassian.net/browse/I7-2129)
	"Quiet supporters from The Eye of the Idol no longer work"
	([PR#114](https://github.com/ganelson/inform/pull/114))
- Fix for Jira bug [I7-2125](https://inform7.atlassian.net/browse/I7-2125)
	"Inblorb copies Cover.png to Small Cover.png"
	([commit 36a6eb0](https://github.com/ganelson/inweb/commit/36a6eb0bd9ff81425a75ff1435002053e09eb59e))
- Fix for Jira bug [I7-2080](https://inform7.atlassian.net/browse/I7-2080)
	"errors in list generation for possession relation"
- Fix for Jira bug [I7-2074](https://inform7.atlassian.net/browse/I7-2074)
	"Documentation recommends scene code that causes soft lock" (about times
	since scene ending sometimes being negative)
	([PR#109](https://github.com/ganelson/inform/pull/109))
- Fix for Jira bug [I7-2021](https://inform7.atlassian.net/browse/I7-2021) = Mantis 2058
	"Multiple 'take all' in an empty room causes a 'Too many activities are going on at once.' error"
	([PR#139](https://github.com/ganelson/inform/pull/139))
- Fix for Jira bug [I7-1973](https://inform7.atlassian.net/browse/I7-1973) = Mantis 2009
	"Standard 'deciding whether all include' rules don't apply to an actor"
	([PR#113](https://github.com/ganelson/inform/pull/113))
- Fix for Jira bug [I7-1929](https://inform7.atlassian.net/browse/I7-1929) = Mantis 1965
	"When defining a kind-of-object via table, properties are misplaced"
	([commit 70fa464](https://github.com/ganelson/inweb/commit/70fa464c677791501bd83efda9bf63802a77e558))
- Fix for Jira bug [I7-256](https://inform7.atlassian.net/browse/I7-256) = Mantis 286 (no, really)
	"Praying is an action out of world applying to one topic with past participle prayed"

## Cosmetic fixes

These affect documentation, or the wording of problem messages or the Index, but
do not really change the compiler or other tools in any way which changes how
source text is read.

> [I7-2685](https://inform7.atlassian.net/browse/I7-2685),
> [I7-2663](https://inform7.atlassian.net/browse/I7-2663),
> [I7-2662](https://inform7.atlassian.net/browse/I7-2662),
> [I7-2640](https://inform7.atlassian.net/browse/I7-2640),
> [I7-2600](https://inform7.atlassian.net/browse/I7-2600),
> [I7-2598](https://inform7.atlassian.net/browse/I7-2598),
> [I7-2594](https://inform7.atlassian.net/browse/I7-2594),
> [I7-2592](https://inform7.atlassian.net/browse/I7-2592),
> [I7-2570](https://inform7.atlassian.net/browse/I7-2570),
> [I7-2529](https://inform7.atlassian.net/browse/I7-2529),
> [I7-2526](https://inform7.atlassian.net/browse/I7-2526),
> [I7-2502](https://inform7.atlassian.net/browse/I7-2502),
> [I7-2481](https://inform7.atlassian.net/browse/I7-2481),
> [I7-2480](https://inform7.atlassian.net/browse/I7-2480),
> [I7-2478](https://inform7.atlassian.net/browse/I7-2478),
> [I7-2473](https://inform7.atlassian.net/browse/I7-2473),
> [I7-2350](https://inform7.atlassian.net/browse/I7-2350),
> [I7-2348](https://inform7.atlassian.net/browse/I7-2348),
> [I7-2319](https://inform7.atlassian.net/browse/I7-2319),
> [I7-2316](https://inform7.atlassian.net/browse/I7-2316),
> [I7-2315](https://inform7.atlassian.net/browse/I7-2315),
> [I7-2311](https://inform7.atlassian.net/browse/I7-2311),
> [I7-2299](https://inform7.atlassian.net/browse/I7-2299),
> [I7-2293](https://inform7.atlassian.net/browse/I7-2293),
> [I7-2286](https://inform7.atlassian.net/browse/I7-2286),
> [I7-2270](https://inform7.atlassian.net/browse/I7-2270),
> [I7-2268](https://inform7.atlassian.net/browse/I7-2268),
> [I7-2221](https://inform7.atlassian.net/browse/I7-2221),
> [I7-2214](https://inform7.atlassian.net/browse/I7-2214),
> [I7-2210](https://inform7.atlassian.net/browse/I7-2210),
> [I7-2120](https://inform7.atlassian.net/browse/I7-2120)

## Bugs fixed but not from tracked reports

- Fix for a "very old quirk of I7 where it generates a `story.gblorb.js` file for
	the interpreter website, but the filename is a lie. It's the base64-encoding
	of the `story.ulx` file, not the `story.gblorb`." (Andrew Plotkin, not from Jira)
- "X is an activity on nothing" would incorrectly create an activity on objects,
	resulting in an immediate contradiction. (Activities on nothing are not often
	useful, which is why this bug has lasted so long.)
- "empty", as an adjective, was defined only on activities and rulebooks based
	on objects

## Bugs fixed in the course of feature additions

Work done on Inform evolution proposal [(IE-0015) World model enforcement](https://github.com/ganelson/inform-evolution/blob/main/proposals/0015-world-model-enforcement.md)
fixes a number of known anomalies in the way that the standard world model
handled containment, incorporation and so on. This enabled a number of bugs to
be closed:

- [I7-2296](https://inform7.atlassian.net/browse/I7-2296)
	on things being privately-named causing their printed names not to be used in room description
- [I7-2220](https://inform7.atlassian.net/browse/I7-2220)
	on the definition of holding
- [I7-2219](https://inform7.atlassian.net/browse/I7-2219)
	on directions being held
- [I7-2178](https://inform7.atlassian.net/browse/I7-2178)
	on "if x is held by a supporter" resulting in false negative
- [I7-2158](https://inform7.atlassian.net/browse/I7-2158)
	on "all" determiner tests failing with relations
- [I7-2128](https://inform7.atlassian.net/browse/I7-2128)
	on holding relation tests failing for containment, support, or incorporation
- [I7-2046 = Mantis 2083](https://inform7.atlassian.net/browse/I7-2046)
	on when containers holding concealed items say they are "(empty)"
- [I7-2036 = Mantis 2073](https://inform7.atlassian.net/browse/I7-2036)
	on inconsistencies when containers or supporters holding concealed items are examined

Similarly, [(IE-0021) No automatic plural synonyms](https://github.com/ganelson/inform-evolution/blob/main/proposals/0021-no-automatic-plural-synonyms.md):

- [I7-1980 = Mantis 2016](https://inform7.atlassian.net/browse/I7-1980)
	on understanding things by plural name of kind

Similarly, [(IE-0042) Release along with separated resources](https://github.com/ganelson/inform-evolution/blob/main/proposals/0042-release-separated-resources.md):

- [I7-2679](https://inform7.atlassian.net/browse/I7-2679)
	on smuggling `.mp3` sound files through the Release mechanism

Similarly, [(IE-0043) Improved comparatives and superlatives](https://github.com/ganelson/inform-evolution/blob/main/proposals/0043-improved-comparatives-and-superlatives.md):

- [I7-2595](https://inform7.atlassian.net/browse/I7-2595)
	on comparatives/superlatives on a scene leading to problems or run-time errors

## Note about intest

- On MacOS, `intest` is supplied inside the app for testing examples in the
	documentation of extension projects: a bug has been fixed which caused the
	test scripts in such examples to be wrongly extracted if characters appeared
	after the final double-quote of the test script (for example, any redundant
	white space). This isn't strictly speaking a core Inform bug fix, but it
	affects some users.
