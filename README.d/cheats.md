# Bash Patterns: Solutions

(Back to [main][bash_patterns])

An assortment of code snippets that illustrate or solve Bash
scripting issues.

## Topics

- Heredocs

- Regular Expressions in Bash

- Traps to Restore Settings

- [Sourcing Includes with Relative Paths][relative_paths]

## Heredocs

A heredoc is a coding construct where a multi-line, formatted
string is delivered as a file to stdin

### Further *Heredoc* information

*Here documents* are covered in the Bash man page, invoke with

~~~sh
man -P 'less -p "Here Documents" bash
~~~
by quoting the search phrase, or
~~~sh
man -P 'less -p Here\ Documents bash
~~~
by escaping spaces in the search phrase that would otherwise
treat the search phrase as multiple commands.



[bash_patterns]: <https://www.github.com/cjungmann/bash_patterns>   "Bash Patterns"
[relative_paths]: <relative_paths.md>                               "relative paths"
