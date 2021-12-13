# list_selector Pattern

[Main README][1]

This pattern displays a scrolling list of items from which a user
may select an item.  The user can indicate the selection with a 
combination of up- or down-arrow keypresses to shift the selection
a single line, and PgUp or PgDn keypresses to shift the selection
by a page length.

This pattern uses optional arguments and an overrideable item-print
function to provide flexibility with respect to how each item looks
while managing the overall organization of which items to display and
which item is currently selected.

Documentation is primarily available in the scripts through function
descriptors and the associated *list_selector_examples* script.

Although this pattern can be used in different applications, it was
created primarily to support the user interface of another project,
[console_color_sets][2], which may also be consulted for ideas about
how to use this BASH pattern.


[1]: <README.md>                                        "main README"
[2]: <https://github.com/cjungmann/console_color_sets>  "console_color_sets"