# Using bash_patterns Sources

The Bash script files in this directory are meant to be
included in other scripts through _source_ statements.

Segregating these files into a subdirectory makes it
possible to use them in multiple projects by making a
symlink to this directory in the directory of the new
project.

The command to make a directory symlink looks like this:

~~~sh
user@host:~/bash_project$ ln -s ~/work/bash_patterns/sources sources
~~~

The contents of the directory can then serve
as a sort of shared library

## Is This a Good Idea?

One might debate whether this is a good strategy.

The argument against using a symlink to the library is that
a project that depends on the library may unexpectedly 'break'
if a library update changes or removes a component of the
library.  Fearing this, a script developer may choose to copy
the library files into a new project directory.  Note, the
option of copying the files is not precluded by having a
library directory.

An argument for using the subdirectory as a library is that
it will be easier for the developer to concentrate on the
value-added work of the new project.

Another argument for using the subdirectory as a library may
be strongest for me, the developer of the library.  Any of my
projects that use this as a library will be vulnerable to
changes as described above.  This vulnerability is an extra
motivation for me to improve and freeze component interfaces
lest I unawaredly break several projects.  By unawaredly I
mean that I won't know that they're broken until I use them.
If considerable time passes between a library change and the
next use of a project, it will be difficult to understand why
the program no longer works.