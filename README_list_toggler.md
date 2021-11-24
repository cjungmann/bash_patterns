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

[1]: <README.md>                                      "Index"
[2]: <README_keypress.md>                             "get_keypress"
[3]: <https://github.com/cjungmann/SchemaServer.git>  "Schema Server"