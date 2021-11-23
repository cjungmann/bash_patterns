# Project bash_patterns

This project is a place for me to isolate solutions and successful
examples of troublesome BASH programming.  I'm tired of having to
search for vaguely-remembered code through all my BASH code
to find solutions.

This README is very limited, with most of the commentary in the
BASH scripts themselves.

The included scripts are:

- **ansi** started as a place to record solutions for
  screen manipulation using console codes.  As such, it
  starts with **pause_for_keypress** and **erase_screen**
  functions.

  **ansi** continues with many color-setting functions,
  then a function to collect function names from BASH,
  distill from the function names the set of colors,
  then execute a loop that displays each color with plain,
  dim, and bold styling.  The output shows all the colors
  that can be generated in a console window using ANSI
  console codes.

  In the script, I suggest a **man** page that can serve
  as an offline reference, and a huge [VT100 page][1].
  for a lot more information and ideas.

- **echoing** includes a fancy echo replacement that hilites
  a portion of a string that is marked out between two delimiters.
  It exploits array handling with different IFS settings and
  converting a string into an array of characters using *sed*.

- [**keypress**][2] defines two keypress functions, *get_keypress*
  and *await_letter* that use a few **read** modes to return a
  representation of a single keypress.  *get_keypress* may return
  a string of multiple characters for non-printing keys like
  function or arrow keys.

  This script also includes another, possibly useful, function,
  *str_contains_chr*, which returns 0/TRUE if a submitted character
  can be found in a string.  It's not named *strchr* because it
  doesn't return the position of the matched char.

- [**get_credentials**][3] is an example of a dialog getting a
  username and password where the password is hidden immediately
  after entry to enhance security against prying eyes.

- The **regexes** script is an exploration and a small
  (but perhaps growing) set of examples of using regular
  expressions in a BASH script.  It ignores (for now) the
  *grep* utility and focuses on `[[ string =~ $regex ]]` notation.

  Some useful references mentioned are the man pages for:
  - *man 7 regex* for Posix flavor used by `[[ =~ ]]` notation.
  - *man 3 pcresyntax*, and *man 3 pcrepattern* are documents
    supporting PCRE (Perl-Compatible Regular Expression) that is
    used by **grep**.

- The [**regexes**][4] page is an exploration of different flavors
  of regular expression, including examples that will hopefully
  help avoid trial-and-error development to discover the appropriate
  character escaping requirements.

- [**useful**][5] includes several functions that are useful for
  making BASH applications.  The script includes some explanatory notes.

- **indirect_arrays** is an exploration of indirect access
  to an array in the global scope of the program.  Requires
  (and checks for) BASH versions 4.3 and up.

- **get_responses** includes two implementations of using
  an array of variable names to define a set of interactions
  getting user input.

- [**list_toggler**][6] implements a method for setting several
  switches in a single dialog.  This script demonstrates
  how to use BASH arrays, associative arrays, and named
  variables.

[1]: <https://vt100.net/docs/vt510-rm/chapter4.html>    "vt100"
[2]: <README_keypress.md>                               "keypress"
[3]: <README_get_credentials.md>                        "get credentials"
[4]: <README_regexes.md>                                "regular expressions"
[5]: <README_useful.md>                                 "random useful patterns"
[6]: <README_list_toggler.md>                           "list toggler"