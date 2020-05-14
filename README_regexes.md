# BASH Regular Expressions

Regular expressions are a powerful tool for processing text, but
I am often frustrated getting matches were I'm am expecting them.
I am pretty comfortable with the syntax, but I spend way more time
than I want debugging expressions due to differing rules on
escaping characters.

Different flavors of Regex processors have different requirements.
Some use meta characters for character classes, like \d for a
digit, \s for space, other flavors use [[:digit:]] and [[:space:]]
instead.

This page will increasingly document some of these differences
with explanations and especially, examples.

## Why *BASH* Regular Expressions

Outside of Linux, there are several additional flavors.  Javascript
is a prime example.  In fact, I love using Regular Expressions in
Javascript because you can specify a function to process matches.

As I am increasingly focusing on Linux development, this document
will ignore the wider world of Regular Expressions.

## Flavors of Regular Expressions

Many basic Linux/Unix commands use regular expressions.  *awk*,
*grep*, and *sed* are the main examples.  These programs recognize
flags that specify regex interpretations.

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