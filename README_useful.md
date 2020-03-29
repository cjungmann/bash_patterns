# Project bash_ideas : useful

[Main README](README.md)

The bottom of this page shows how one can use these simple functions
from the command line.

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

- **get_ip_address**\
  Returns a list of network interfaces by name and ip address

- **is_local_ip**\
  Returns 0 (true) if the passed IP address is a LAN address,
  1 otherwise.  Call like this:\

  ~~~sh
  tryip=192.168.0.10
  if is_local_ip $tryip; then
     echo "$tryip is a LAN address"
  else
     echo "$tryip is a WAN address"
  fi
  ~~~

  
## Use *useful* On the Command Line

Use the **source** command to load **useful** as a library,
then call a useful function.

For example, get the list of IP addresses with

`source useful; get_ip_address1`


  
