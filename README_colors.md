# Project bash_patterns : colors

[Main README](README.md)

I find it very helpful to see colors when scanning a directory's
contents.  By default, **ls** produces white characters output,
but there is an argument to enable colored output.

## Enable *ls* Colors

The color-enabling argument is different on different environments.
Sometime **ls** color is enables with the **-G** option, other times
it responds to the **--color** option.  Consult the **ls** man page
to see which option should be used.

## Use *alias* to Sustain Colors

It's not very convient to constantly add color option, so it is
helpful to make an alias according to your environment.  I make
sure an *alias* is defined for my console sessions.  Since I use
**bash**, I ensure that **ls** alias is in `~/.bashrc`, directly
or sourced.

## Improve Colors (the LS_COLORS variable)

I primarily work in a console window with a black background.  The
default colors of **ls** are often too dark to easily read.  The
**ls** colors can be changed by setting the environment variable
**LS_COLORS**  (see `man bash`, `man ls`, and `man dircolors`)

On fresh systems, the **LS_COLORS** environment variable may be
undefined.  In this case, the default set of **LS_COLORS** can
be generated with the **dircolors** command (which is not available
for BSD).  Type the following command to generate an **LS_COLORS**
definition that is in force:

~~~sh
$ dircolors -p > ls_colors.txt
~~~


## LS_COLORS key

The **LS_COLORS** value includes many cryptic two-letter codes.
The two-letter codes are explained in the *dircolors -p*

-- **rs**  reset: reset to "normal" color
-- **di**  directory
-- **ln**  link
-- **mh**  multi-hard-link
-- **pi**  (FIFO) pipe
-- **so**  socket
-- **do**  door (?)
-- **bd**  block device driver
-- **cd**  character device driver
-- **or**  orphan, symlink to nonexistent or non-'stat'able file
-- **mi**  missing file
-- **su**  setuid file (mode u+s)(?)
-- **sg**  setgid file (mode g+s)(?)
-- **ca**  capability (file with capability, but not executable?)
-- **tw**  sticky, other-writable (mode +t o+w)
-- **ow**  other-writable, non-sticky, other-writable (mode o+w)
-- **st**  sticky (directory with sticky-bit set (+t) but not other-writable (mode o-w)
-- **ex**  executable

## Selecting Colors

I am writing a script to select background and foreground colors on
the console.  I've wanted a tool like this and thought it would be a
good BASH exercise.



The console uses escape codes to trigger colors.  I found this
[Stack Exchange answer][1] to be a useful, if not definitive,
reference.




[1]: <https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences> "stack exchange answer"