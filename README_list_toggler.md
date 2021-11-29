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
presses in order to move the highlighting between options.  This
function is copied, without comments, from the **keypress** script.

## Usage

This script is designed to be included in another script with a
`source` statement.  Look at script **list_toggler_example** for
guidance on the use of **list_toggler**.

### Customization

There are several things that can be customized with the stock
**list_toggler** code:

- **Introduction Text: (*T_INTRO*)**  
  This is text that will be printed just before the list of options.
  The default value is an empty string.

- **Prompt Text: (*T_PROMPT*)**  
  This text will be printed just after the list of options.  The
  default string contains instructions for usage.  You may want to
  improve the prompt or add extra information according to your domain.

- **Choices Display: (function *toggler_print_choice*)**  
  Overriding this function allows your script to present the options
  according to the needs of your application.  Look at the default
  `toggler_print_choice` function in **list_toggler** and the override
  `toggler_print_choice` override in **list_toggler_example**.

- **Customizing Control Keys (*TGROUP_XXX* and *TKEYS_XXX*)**  
  These variables are strings that may include multiple keys
  separated by the '|' character.  There are *TGROUP_XXX* strings
  for each user-available action (UP, DOWN, TOGGLE, EXEC, QUIT, and HELP),
  and *TKEYS_XXX*, when defined, should provide user-readable names
  for keys in the associated *TGROUP_XXX*

  - **TGROUP_XXX**   
    The contents of each *TGROUP_XXX* variable defines the keys assigned
    to that particular action.  Multiple keys in a group must be separated
    with a '|' character and must be apropriate for **glob** processing
    in the BASE **case** command.

    While most keys generate a single character, many keys generate a
    string of characters.  These multi-char keys include the *up-arrow*,
    *PgDn*, and *shift-TAB*.  When including multi-char keys, be careful
    with escaping appropriate characters.  In particular, most multi-char
    key strings include the `[` character, which must be preceeded by
    two backslashes or it will be interpreted as an introduction to a
    glob character class.  For example, the *up-arrow* key generates three
    characters, ESCAPE, '[', and 'A', which should be rendered as this
    string: `$'\e\\[A'`.  Using `$'...'` is necessary for '\e' to be
    interpreted as an ESCAPE character.

  - **TKEYS_XXX**  
    This string is used for generating a help screen.  When defined for
    a given *TGROUP_XXX* variable, provides user-readable names for the
    key strings in the variable.  This is important for multi-char keys
    that begin with an ESCAPE character.

    If there is no *TKEYS_XXX* for a given *TGROUP_XXX*, the contents
    of *TGROUP_XXX* will 

  Look at the **list_toggler** and **list_toggler_example** scripts for
  how these variables are defined.  You may find the *keypress_example*
  script useful for showing the string output of keypresses.
  

[1]: <README.md>                                      "Index"
[2]: <README_keypress.md>                             "get_keypress"
[3]: <https://github.com/cjungmann/SchemaServer.git>  "Schema Server"