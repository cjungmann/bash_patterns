# Bash Patterns: TUI Scripts

(Back to [main][bash_patterns])

Invariably, finally understanding the issues around a problem leads
to more ideas, then more problems, questions, and solutions.  This
section describes a set of scripts that can be used to create
Bash-based applications.

## Installation

The *Sources* scripts are a resource for creating Bash-based TUI programs.
If several *Sources* scripts are installed, it will be convenient to put
the *Sources* in an easily-located directory and then make symbolic links
to the *Sources* directory under directories with applications that need
those scripts.

For example, on my laptop, I have cloned the
[Bash Patterns][bash_patterns] project under my *home* directory
(`~/work/bash_patterns`).  When I created the [man links][manlinks]
project, I created a new directory, made a syboliic link to *Sources*,
then wrote the *manlinks* script.

~~~sh
user@host:~$ cd work
user@host:~/work$ git clone https://github.com/cjungmann/bash_patterns.git
user@host:~/work$ mkdir manlinks
user@host:~/work$ cd manlinks
user@host:~/work/manlinks$ ln -s ~/work/bash_patterns/sources sources
user@host:~/work/manlinks$ emacs manlinks
~~~




[bash_patterns]: <https://www.github.com/cjungmann/bash_patterns>   "Bash Patterns"
[manlinks]:     <https://www.github.com/cjunmann/manlinks>    "manlinks"