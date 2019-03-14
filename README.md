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