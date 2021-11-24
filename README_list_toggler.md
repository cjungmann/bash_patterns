# list_toggler Pattern

[Main README][1]

Using **BASH arrays**, **associative arrays**, **named variables**,
and [get_keypress][2] to create a console-based multi-selection
interaction.

## Inspiration for the script

As I design more complex setup scripts, it has become more important
to allow an end-user to opt out of some parts.  For example, making a
FAMP (FreeBSD/Apache/Mariadb/PHP) server involves installing Apache,
MariaDB, and PHP.  It's more convenient to install all parts with a
single script, but in some cases, the user may prefer to omit one of
the packages.  For example, the [Schema Server][3] needs Apache and
MariaDB, but not PHP.

## Design details

**Named Variables** are analgous to passing variables by address or
reference in C++.  Named variables are used here to create, pass, and
return complex structured data to calling functions.

**Associative Arrays** accesses array elements by a string key rather
than an integer index.  This simplifies tracking random values in the
order that the user prefers.

**Arrays** are used in this script to retain the key order that is
lost when collecting the keys from an associative array.  If key order
were not important, getting the keys from `${!choices[@]}` would be
sufficient to iterate the values in the associative array.

**get_keypress** function is used to identify up and down arrow key
presses in order to move the highlighting between options.

## Usage

This script is designed to be included in another script with a
`source` statement.  Look at script **list_toggler_example** for
guidance on the use of **list_toggler**.

### Customization

There are several things that can be customized with the stock
**list_toggler** code:

- **Introduction Text: *T_INTRO* **
  This is text that will be printed just before the list of options.
  The default value is an empty string.

- **Prompt Text: *T_PROMPT* **  
  This text will be printed just after the list of options.  The
  default string contains instructions for usage.  You may want to
  improve the prompt or add extra information according to your domain.

- **Choices Display: *toggler_print_choice()* **  
  Overriding this function allows your script to present the options
  according to the needs of your application.  Look at the default
  `toggler_print_choice` function in **list_toggler** and the override
  `toggler_print_choice` override in **list_toggler_example**.

- **Customizing Control Keys *T_UP_KEYS* and *T_DOWN_KEYS* **  
  *This doesn't work (yet)* because I can't figure out how to define
  a string with multiple control characters that is successfully
  parsed with `+($UP_KEYS)`.

  So for now, the up-arrow and shift-tab keys move the selecion
  up, and the down-arrow and tab keys move the selection down.

  The following is a record of my efforts in solving this, and a
  demonstration of how the `+(...|...)` feature is supposed to work.

  ~~~sh
  shopt -e extglob

  # define multi-char keypresses in use:
  T_UP_ARROW=$'\e[A'
  T_DOWN_ARROW=$'\e[B'
  T_TAB=$'\t'
  T_SHIFT_TAB=$'\e[Z'

  # Group equivalents:  
  T_UP_KEYS=$T_UP_ARROW|$T_SHIFT_TAB
  T_DOWN_KEYS=$T_DOWN_ARROW|$T_TAB

  keyp=$( get_keypress )
  case "$keyp" in
     +($T_UP_KEYS) ) move_selection_up ;;
     +($T_DOWN_KEYS) ) move_selection_down ;;
  esac
  ~~~

  even though this does work:

  ~~~sh
  shopt -e extglob
  T_MATCHES='a|b|c'
  KEYP=
  read -sn1 KEYP
  case $KEYP in
     +($T_MATCHES) ) echo "Matched!" ;;
  esac
  ~~~

  The difference must be in how UP_KEYS and DOWN_KEYS are defined, but
  I can't figure out how to assign them properly.


[1]: <README.md>                                      "Index"
[2]: <README_keypress.md>                             "get_keypress"
[3]: <https://github.com/cjungmann/SchemaServer.git>  "Schema Server"