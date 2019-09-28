# Project bash_ideas : useful

[Main README](README.md)

There are several very simple functions that may be interesting:

- **is_root**\
  test if root user (e.g. sudo)

- **pause_for_keypress**\
  waits for any single keypress.

- **reset_screen**\
  Terminal function clears screen and places cursor at top, left.

- **clear_line**\
  Clears from cursor position to right-edge of screen.  May be
  easier to use than padding line contents.

- **unset_text_colors**\
  Issues terminal escape sequence to cancel text changes.

- **set_text_background**\
  accepts a color parameter (black, red, green, brown, yellow,
  blue, magenta, cyan, white) to send terminal escape sequence
  to set the background to indicated color.

- **set_text_foreground**\
  accepts a color parameter (black, red, green, brown, yellow,
  blue, magenta, cyan, white) to send terminal escape sequence
  to set the text to indicated color.

The next few functions are more complicated and also illustrate
some BASH coding protocols.

- **cecho**\
  Use like **echo**, except that only the first parameter is
  written to the screen, with the optional second parameter
  serving as the foreground color and the optional third
  parameter as background.

  Illustrates replacing missing parameter values with default
  values using `${string:-default}`.

- **get_keypress**\
  Gets a single keypress.  This sounds simple, but many key
  presses return a short string of characters instead of a
  single character.  This function recognizes when a keypress
  is represented by several characters and packages them to
  be judged in the calling function.

  Illustrates using builtin **read** function to detect
  and collect extra characters.
  

  
