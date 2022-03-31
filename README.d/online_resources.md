# Bash Patterns: Online Resources

(Back to [main][bash_patterns])

These are some web pages I found during research that either nicely
explained a problem or solution, or are useful references I expect
that I'd like to revisit.

## References

### Style Guide

- **[Google Shell Script Style Guide][styleguide]**  
  Having a consistent style makes it easier to read and understand
  code.  I try to be aware of how my coding style helps or hinders
  my work, making adjustments from project to project.  Google has
  published their style guide which I intend to consult when I have
  to make style decisions.

### Regular Expressions

Bash uses regular expressions (AKA *regex*) in tests and parameter
expansions.  Mastering regular expressions is very empowering in Bash
and many other environments.  The following links are useful:

- **[Regular Expression Flavors][re.flavors]**  
  Different regex evaluators may have different conventions for
  escaping ambiguous characters, may have different expressions of
  character classes, and may more or less completely implement
  aspects of the regex language.

- **[Regular Expression Info][re.info]**  
  This page contains links to tutorials for beginning or more
  advanced users of regular expressions.

### Console Programming

For text user interfaces (TUI), text characters are written to the
console.  There is a widely-distributed library **curses** that
mediates between programs and the screen, but **curses** ultimately
sends escape sequences to the console to influence how and where the
text appears.  In [bash_patterns][bash_patterns], I have employed
raw console escape codes.

- **man console_codes**  
  This is built into Linux distributions, can be installed on BSD.
  The man page is the first and easiest place to look for console
  programming information.

- **[VT Codes][console.1]**  
  Reference to codes that unlock terminal's abilities

- **[Console Colors][console.2]**  
  Presenting different colored is a eye-catching way to emphasize
  things.

### Character Constants

There are several characters for which one might want to recognize
in a test or send to the console for some effect.  The guidelines are
simple enough, but a [reference][ansi_c_quoting] is still nice.










[bash_patterns]: <https://www.github.com/cjungmann/bash_patterns>   "Bash Patterns"
[styleguide]: <https://google.github.io/styleguide/shellguide.html>  "Google Shell Style Guide"
[re.flavors]: <https://gist.github.com/CMCDragonkai/6c933f4a7d713ef712145c5eb94a1816> "Regular expression flavors"
[re.info]: <https://www.regular-expressions.info/> "Regular expression.info"
[console.1]: <https://vt100.net/docs/vt510-rm/chapter4.html>    "vt codes"
[console.2]: <https://github.com/cjungmann/console_color_sets>  "console_colors"
[ansi_c_quoting]: <https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html>  "ANSI-C Quoting"