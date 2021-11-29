# Project bash_patterns : keypress

[Main README](README.md)

It is common to need to detect individual keypresses in an interactive
program.  While many keypresses emit a single character, special keys
like arrow and function keys often return several characters for a single
keypress.  Detecting keypresses in BASH poses some difficulties that
do not exist in other languages, and the `keypress` script demonstrates
how to overcome some of these difficulties.

In the **keypress** script, there are two keypress-getting functions,
**get_keypress** and a more capable **key_keypress_var**, the main
difference being how the calling function acquires the result.

- **get_keypress** returns the keypress character string with an
  **echo**.  This works fine for most keys, but may fail to detect
  **IFS** characters at either end.  What this means in practice is
  that **get_keypress** cannot reliably return a result for ENTER,
  which may be clobbered by the **IFS** value in the calling
  function.

- **get_keypress_var** thwarts the **IFS** problem by using a
  *nameref* variable from the calling function, thus avoiding the
  use of **echo**.  

After a very simple example, the *get_yes_or_no* function that waits for
a single keypress, this script also includes a function, *get_keypress*,
followed by some examples of strings that can be used to interpret the
return value of *get_keypress*.  The benefit of this function is that
it can return a multi-character string as the appropriate representation
of a keystroke.

The *get_keypress* function takes advantage of *read* features:

- **-n 1** option reads a single character, without waiting for
  a delimiter (e.g. the ENTER key).

- **-t 0**, through an exit value of 0, indicates that there are
  additional characters in the input buffer.  In *get_keypress*,
  this is used in a loop condition to collect extra characters
  resulting from a keypress.

For cases with a limited number of acceptable responses, the
*await_letter* function takes a string of acceptable characters
and only returns when one of those characters have been typed.
Look at the example section of the *keypress* script.

## Example Recognition Strings

Use [*ANSI-C Quoting*](https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html\#ANSI_002dC-Quoting)
to include create or recognize control characters.

Control-key characters can be tested with $'\c.':

~~~sh
declare keypress_ctrl_n=$'\cn'   \# control-n
declare keypress_ctrl_p=$'\cp'   \# control-p
~~~

The ESCAPE character may be a prefix to a keystroke
string:

~~~sh
declare keypress_down_array=$'\e[B'
declare keypress_up_array=$'\e[A'
~~~

In EMACS, a developer can use C-q, ESC to enter an escape character.
(see documentation: info emacs -n "Inserting Text")
~~~sh
declare keypress_down_arrow='^[[B'
declare keypress_up_array='^[[A'
~~~



