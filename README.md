# Project bash_ideas

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
  as an offline reference, and a huge [VT100 page](https://vt100.net/docs/vt510-rm/chapter4.html).
  for a lot more information and ideas.

- **echoing** includes a fancy echo replacement that hilites
  a portion of a string that is marked out between two delimiters.
  It exploits array handling with different IFS settings and
  converting a string into an array of characters using *sed*.

- **regexes** is an exploration and a small (but perhaps
  growing) set of examples of using regular expressions
  in a BASH script.  It ignores (for now) the *grep*
  utility and focuses on *[[ string =~ $regex ]]* notation.

  Some useful references mentioned are the man pages for:
  - *man 7 regex* for Posix flavor used by [[ =~ ]] notation.
  - *man 3 pcresyntax*, and *man 3 pcrepattern* are documents
    supporting PCRE (Perl-Compatible Regular Expression) that is
    used by **grep**.

- **useful** includes several functions that are useful for
  making BASH applications.  The [useful README](README_useful.md)
  includes explanations of some functions and concepts.

- **indirect_arrays** is an exploration of indirect access
  to an array in the global scope of the program.  Requires
  (and checks for) BASH versions 4.3 and up.

