# BASH Regular Expressions

Regular expressions are text strings containing instructions on how
to match part or all of a target text string.

Regular expressions are widely used, appearing in command line tools
like *awk*, *grep*, and *sed*, as well as in nearly all programming
languages.  Mastery of regular expressions is a valuable skill.

## Document Objective

There are several slightly-different conventions for regular
expressions, and I often only produce a useful regular expression
after a period of trial-and-error, changing the set of characters
that are escaped.  I want to create a reference that helps me avoid
the trail-end-error step so I can quickly and confidently create
useful regular expressions.

## References

Here are a couple of pages that are useful for sussing out regular
expressions:

- [List of Regular Expression Flavors][flavors]
- [Regular-expressions.info][re.info]

## Control Characters

Regular expressions are text string instructions for matching and
extracting strings and portions of strings.  As text strings, however,
regular expressions often include characters that serve two purposes,
either to indicate characters to match or as control characters that
indicate processing instructions.  When a character can serve two
purposes, it is necessary to indicate which purpose the character
serves when it is found in a regular expression.

The main control characters are:
- **(** and **)** for collecting matches into groups OR to contain
  a set of symbols like lookahead or lookbehind instructions
- **[** and **]** for identifying a collection of characters
  (AKA a character class)
- **{** and **}** enclose match count instructions
- __?__, __+__, and __*__ quantifier meta characters for indicating
  the number of matches that can be accepted in a target string
- __^__ and __$__ to match the beginning and end of a string or
  line
- __|__ separates alternate equivalent matches
- __.__ is a character wildcard, matching any character

## Regular Expression Flavors

There are many regular expression engines, each with their own
'flavor', or set of conventions.  You can find an [extensive list][flavors]
of flavors online.  In this document of Bash patterns, we will
focus on three widely-used flavors, PCRE (Perl-compatible regular
expressions), Posix ERE (extended regular expressions), and Posix
BRE (basic regular expressions), which are sometimes considered
to be obsolete.

Each of the three flavors has different conventions, including
which characters to escape and when, and how to indicate canned
character classes.  The differences are noted below as a
reference section to aid writing regular expressions.

### PCRE (Perl-Compatibly Regular Expressions)

- **Meta Characters**:  escaped meta characters match the
  character in the target text, unescaped meta characters are
  read as a meta character.

  example: __*__ matches any character, __/*__ matches an asterisk
  __(__ matches an open parensis, __\(__ introduces a group

- **Character Classes**: in addition to characters and sequences in
  square brackets, there are meta characters that represent character
  classes.

  example: **\s** matches any space, **\S** matches any non-space

- **PCRE man reference**:  `man 3 pcrepattern` and `man 3 pcresyntax`
  to see a complete reference of character classes and control
  characters.

- PCRE syntax used for Bash regular expressions.

### Posix ERE (Extended Regular Expressions)

- **Meta Characters**: __.__, __^__, __$__, and __*__ are meta
  characters unless escaped.  Other meta characters must be escaped
  to be meta, otherwise they match the character of which they are
  composed.

  examples:  __.__ matches any character, __\.__ matches a period  
    BUT __(__ matches an open parenthsis, __\(__ introduces a group.

- **Character Classes**: in addition to characters and sequences in
  square brackets, there are standard character class names to be
  called from within `[:` and `:]`

  example:  [[:alpha:]] for alphabetic characters, [[:space:]] for
  whitespace characters, [[:punct:]] for punctuation characters.

- **BRE man reference**: `man 7 regex`

- ERE is used by default in **awk** and is an option for **sed**
  and **grep**

### Posix BRE (Basic Regular Expressions)

- **Meta Characters**: meta characters are only meta
  characters if they are escaped, otherwise they simply match
  their characters in the target text.

  example:  **(** matches a parenthesis, **\(** introduces a group
  __*__ matches an asterisk, __\*__ is a wildcard character.
  __+__ matches a plus character, __\+__ looks for one or more matches
  of the previous atom

- **Character Classes**:  are also known as *bracket expressions*, and
  are indicated by a name enclosed by `[:` and `:]`, which are, in turn,
  enclosed by the character class brackets.

  examples:  [[:alpha:]] for alphabetic characters, [[:alnum:]] for
  alpha-numeric characters.

- **BRE man reference**: `man 7 regex`

- BRE is the default for Posix **grep** and **sed**

## Other Construction Considerations

Knowing regular expression syntax and patterns is ofthen only the
beginning.  Command line programs like **awk**, **grep**, and **sed**
read the regular expressions as text strings, which make them subject
to additional interpretation according to the shell in which they
are invoked.

Things can get very confusing in Bash.  Some characters expand when
they are used outside of quotes.  For example, the asterisk, "__*__"
expands to the list of file names when used unquoted, but is left
alone when in a quote-enclosed string.  Other characters perform
expansions only within double-quoted strings, but not when unquoted
or enclosed in single-quote (apostrophe) strings.  The dollar sign
"__$__" is an example.

Meta characters and special shell character characters often need to
be escaped with a preceding backslash "__\__" to ensure the proper
interpretation.  In some cases, it may be required to use a
double-backslash to preserve the backslash that must precede a
regular expression meta character.

## Examples Section

The following content consists of examples I wrote earlier to
demonstrate different regular expression considerations.

### BRE (Basic Regular Expression)

This has been the default *grep* interpretation.  Meta-characters
like *?*, *+*, *(* must be escaped when used as an expression
character.  For example:

| Regex | Match |
| `(foobar)` | will match match *(foobar)* with included parentheses
| `\\(foobar\\)` | will match *foobar* into a group that can be back-referenced

### ERE (Extended Regular Expression)

In *grep*, ERE and BRE are now the same.

### PCRE (Perl-Compatible Regular Expression)

Refer to *man* pages for more information about PCRE.  Start
with **pcresyntax(3)** and **pcrepattern(3)** for details
about the requirements of PCRE.

## BASH Shell Regular Expressions

This particular environment inspired me to create this page.
String assignment in BASH often does not require enclosing
quotes, and in fact, strings within double-quotes may perform
some substitutions, so quotes and their type must be carefully
considered.

The usual advice is to store the regular expression in a
variable and use the unquoted variable in the judging:

~~~sh
declare myregex='^.*(foobar).*$'
if [[ "$1" =~ $myregex ]]; then
   use_regex "${BASH_REMATCH[1]}"
fi
~~~

### raw_extract_time

Let's match a time string where the time parts are
separated by colons (*:*):

~~~sh
[[ $( date -Iseconds ) =~ ([[:digit:]]{2}):([[:digit:]]{2}):([[:digit:]]{2}) ]]
echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
~~~

Note that there is no escaping characters in this example.
The *(* and *{* characters are interpreted as grouping
and repitition operators.  If the matched string must
include one of these characters, it must be escaped

### Extract EMACS Version Number

This example includes an escaped character.  The period (*.*)
is a regular expression meta-character that matches any
character.  If the matched string must include a period,
it must be escaped to prevent if from matching any single
character.

~~~sh
[[ $( emacs --version ) =~ ([[:digit:]]+)\.[[:digit:]]+ ]]
echo "${BASH_REMATCH[1]}"
~~~

## SED Regular Expressions

Unaltered *sed* use BRE rules, and meta-characters meant to
be interpreted as such must be escaped.  Unescaped meta-characters
represent themselves in a string.  Consider the following
expression:

~~~sh
sed 's/#\\(net.ipv4.ip_forward\\.*\\)/\\1/' /etc/sysctl.conf
~~~

The grouping parentheses around the string are escaped,
as is the meta-character period that matches the rest of the
line.  Surprisingly, the asterisk character following the
period should not be escaped, or I should say, the match
fails if the asterisk is escaped.

Notice that the periods that separate the substrings are
**not** escaped.  They are meant to match actual periods
in the text.  If these periods are escaped, they still
match the periods in the text, but they might also match
a typo where one of the periods is replaces by a non-period
character.


[flavors]: <https://gist.github.com/CMCDragonkai/6c933f4a7d713ef712145c5eb94a1816> "Regular expression flavors"
[re.info]: <https://www.regular-expressions.info/> "Regular expression.info"