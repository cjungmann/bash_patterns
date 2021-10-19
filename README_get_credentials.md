# Project bash_patterns: get_credentials

[Main README](README.md)

Inspired by the lack of the `-s` option for the `read`
command on FreeBSD (for non-echoed characters), I decided to
come up with a BASH pattern for entering a password that
allows the user to see what is typed until pressing **ENTER**,
upon which the password string is overwritten with dashes
to hide it from prying eyes.

One might argue that this is even better than the conventional
silent password entry.  The problem with silent entry is that
you can't see if you make a typing mistake.  This can be a major
problem when setting a new password: if you make a hidden mistake,
you may never be able to reproduce it to get access to the
password-protected asset you are trying to protect.

This script includes a function that runs a dialog, which includes
these features:

- Uses **nameref** variables for indirect access to variables in
  the calling context's scope.  The username and password values
  are "returned" in these variables.

- Uses **console codes** (see `man console_codes`) to reposition
  the cursor to the beginning of the text entry, using **ESC[1F**
  to move up one line to column 1, then **ESC[${#pwprompt}C**
  to move right the number of characters in the prompt.

- Hides the just-entered password upon pressing ENTER.

- Loops until paired password and repeat values match.

