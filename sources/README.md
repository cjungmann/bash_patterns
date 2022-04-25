# Using bash_patterns Sources

A funny thing happened while I was accumulating experiments and
ideas: the collection began to coalesce.  I started to think about
how to a simple idea could be extended to provide support for many
kinds of Text User-Interface (TUI) interactions.

The Bash script files in this directory are meant to be included in
other scripts through _source_ statements.

Segregating these files into a subdirectory makes it possible to use
them in multiple projects by making a symlink to this directory in
the directory of the new project.

## Using Sources

The scripts in *sources* are designed to be simultaneously used by
several Bash programs.  As long as a Bash program resides in a
directory that includes a copy or link to the *sources* directory
through the `source` Bash command, it should be able to find and load
these scripts.

### Prepare to Use Sources

Any Bash program that intends to use *sources* file needs to know how
to find them.  There are two general methods:

1. Use a hard-coded reference to the *sources* directory.

2. Include a symbolic link to the *sources* directory in the
   directory that hosts to Bash script using *sources*.

This guide shows how to setup the symbolic link approach.

#### Making a Symbolic Link

The command to make a directory symlink looks like this:

~~~sh
user@host:~$ cd my_cool_bash_project
user@host:~/my_cool_bash_project$ ln -s ~/Downloads/bash_patterns/sources sources
~~~

> The assumed location for **bash_patterns** is in
> *~/Downloads/bash_patterns*.  Make appropriate adjustments to the
> link location if the project resides somewhere else.

#### Prepare Bash Script To Find *sources*

Useful Bash scripts will often be installed by copy or link in some
*bin* directory that is included in the **$PATH** variable, like
`/usr/bin` or `/usr/local/bin` or '~/.local/bin`.  If the Bash script
hosting directory includes a copy or link to *sources*, 


## Is This a Good Idea?

One might debate whether this is a good strategy.

The argument against using a symlink to the library is that a project
that depends on the library may unexpectedly 'break' if a library
update changes or removes a component of the library.  Fearing this,
a script developer may choose to copy the library files into a new
project directory.  Note, the option of copying the files is not
precluded by having a library directory.

An argument for using the subdirectory as a library is that it will
be easier for the developer to concentrate on the value-added work of
the new project.

Another argument for using the subdirectory as a library may be
strongest for me, the developer of the library.  Any of my projects
that use this as a library will be vulnerable to changes as described
above.  This vulnerability is an extra motivation for me to improve
and freeze component interfaces lest I unawaredly break several
projects.  By unawaredly I mean that I won't know that they're broken
until I use them. If considerable time passes between a library
change and the next use of a project, it will be difficult to
understand why the program no longer works.