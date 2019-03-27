# Project bash_ideas

This project is a place for me to isolate solutions and successful
examples of troublesome BASH programming.  I'm tired of having to
search for vaguely-remembered code through all my BASH code
to find solutions.

This README is very limited, with most of the commentary in the
BASH scripts themselves.

The included scripts are:

- **indirect_arrays** is an exploration of indirect access
  to an array in the global scope of the program.  Requires
  (and checks for) BASH versions 4.3 and up.

- **regexes** is an exploration and a small (but perhaps
  growing) set of examples of using regular expressions
  in a BASH script.  It ignores (for now) the *grep*
  utility and focuses on *[[ string =~ $regex ]]* notation.

- **echoing** includes a fancy echo replacement that hilites
  a portion of a string that is marked out between two delimiters.
  It exploits array handling with different IFS settings and
  converting a string into an array of characters using *sed*.

  Some useful references mentioned are the man pages for:
  - *man 7 regex* for Posix flavor used by [[ =~ ]] notation.
  - *man 3 pcresyntax*, and *man 3 pcrepattern* are documents
    supporting PCRE (Perl-Compatible Regular Expression) that is
    used by **grep**.

  