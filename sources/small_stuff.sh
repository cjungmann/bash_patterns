# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# shellcheck disable=SC2206 # don't warn about initializing arrays with unquoted variables.
# shellcheck disable=SC2059 # skip printf format variables warnings (it thinks $'\e' is a variable)
# shellcheck disable=SC2034 # "unused" nameref variables are read from in calling function

# True if Bash verion is recent enough for these scripts.
# That is, Bash version 4.3 or later.
sufficient_bash_version()
{
    local -i major="${BASH_VERSION[0]}"
    local -i minor="${BASH_VERSION[1]}"
    (( major > 4 || ( major == 4 && minor > 3 ) ))
}

# @def Console-code screen functions
# These functions use console codes (see man console_codes) to
# set or read certain screen characteristics.

# Clear screen, cursor to origin
reset_screen() { echo -n "[2J[1;1H"; }

# Turn OFF console echo without regard to current echo setting
disable_echo() { stty -echo; }
# Turn ON console echo without regard to current echo setting
enable_echo()  { stty echo; }

# Disables default auto-wrap: discard characters that extend past
# the right of the screen.
disable_autowrap() { echo -n $'\e[?7l'; }

# Enables default auto-wrap: for character that would print past
# the right of the screen, continue printing on the next line.
enable_autowrap() { echo -n $'\e[?7h'; }

set_window_title() { echo -ne $'\e]2;'"$1"$'\a'; }

# @def Cursor manipulation
#
# The following functions hide, show, or move the cursor.  It
# includes the function get_screen_size() because it informs
# many cursor positioning decisions.

# Console-code that prevent display of cursor.
hide_cursor() { echo -n $'\e[?25l'; }
# Console-code that enables display of cursor.
show_cursor() { echo -n $'\e[?25h'; }

# Returns rows and columns size of screen in nameref variables.
#
# WARNING/NOTE: won't work in subshell.  See get_cursor_position().
#
# Args
#    (string):  name of variable for rows value
#    (string):  name of variable for columns value
get_screen_size()
{
    local -i csave rsave
    get_cursor_position "rsave" "csave"
    set_cursor_position 999 999
    get_cursor_position "$1" "$2"
    set_cursor_position "$rsave" "$csave"
}

# Get the current cursor position from the terminal, returning the
# values in nameref variables
#
# WARNING/NOTE: this function will not work in a subshell because
# the console response to stdout will be redirected before we can
# read it.
#
# Args
#    (string):   optional name of rows variable
#    (string):   optionalname of columns variable
get_cursor_position()
{
    local -i brows bcols
    local -n gcp_rows="${1:-brows}"
    local -n gcp_cols="${2:-bcols}"

    read -sr -dR -p $'\e[6n' REPLY

    # extract the string-ending, semicolon-separated numbers
    local re='\[([[:digit:]]+;[[:digit:]]+)$'
    if [[ "$REPLY" =~ $re ]]; then
        REPLY="${BASH_REMATCH[1]}"
    else
        REPLY="${REPLY#*[}"
    fi

    local IFS=';'
    local -a arr
    arr=( $REPLY )

    gcp_rows="${arr[0]}"
    gcp_cols="${arr[1]}"
}


# Move the cursor to specified screen location
#
# Args
#    (integer):    row number
#    (integer):    column number
set_cursor_position()
{
    local -i row="${1:-1}"
    local -i col="${2:-1}"

    if [ "$col" -lt 0 -o "$row" -lt 0 ]; then
        echo "Unexpected missing parameter!" >&2
        exit 1
    fi

    printf $'\e['"${row};${col}H"
}

# Move cursor to specified column of current row.
set_cursor_column() { echo -en $'\e['"${1}G"; }

# @def Conversion functions

# shellcheck disable=SC2046,SC2059  # quiet printf scolding

# Returns ASCII character when given an integer value.
char_from_val() { printf $(printf "\\%03o" "$1"); }
# Returns an integer value associated with an ASCII character
val_from_char() { LC_CTYPE=C; printf '%d' "'$1"; }


# Quick array concatenation without side-effects
#
# Args
#    (name-out):   variable to which output is written
#    (name-in):    array to be concatenated
#    (string):     optional delimiter character to go between elements,
#                  concatenating without delimiters if left blank.
concat_array()
{
    local -n ca_output="$1"
    local -n ca_array="$2"
    local delim="$3"

    local OIFS="$IFS"
    local IFS="$delim"
    ca_output="${ca_array[*]}"
    IFS="$OIFS"
}

# Quick string split to array without side-effects
#
# Args
#    (name-out):  name of array to which the output will be written
#    (string):    string to be split
#    (string):    delimiter character marking element borders
array_from_string()
{
    local -n afs_output="$1"
    local input="$2"
    local delim="$3"

    local OIFS="$IFS"
    local IFS="$delim"
    afs_output=( $input )
    IFS="$OIFS"
}

# @def String search functions


# Nameref version of strstrndx
#
# Gets 0-based character position in first string of the first
# occurance of the second string
# Args
#   (name-out):  name of integer variable to which result is written
#   (string):    haystack, string to be searched
#   (string):    needle, substring to be sought in haystack
#
# Returns
#   *true*  (0) if found
#   *false* (1) if not found
strstrndx_nameref()
{
    local -n sn_ndx="$1"
    local -i len1="${#2}"
    local sub="${2#*$3}"
    local -i sublen="${#sub}"
    if [ "$len1" -eq "$sublen" ]; then
        return 1
    fi

    (( sn_ndx = len1 - sublen - "${#3}" ))
    return 0
}

# Gets 0-based character position in first string of the first
# occurance of the second string
# Args
#   (string):    haystack, string to be searched
#   (string):    needle, substring to be sought in haystack
#
# Returns
#    echos integer position of needle in haystack
#    *true* if substring found
#    *false* if not found
strstrndx()
{
    local -i len1="${#1}"
    local sub="${1#*$2}"
    local -i sublen="${#sub}"
    if [ "$len1" -eq "$sublen" ]; then
        echo -1
        return 1
    fi

    echo $(( len1 - sublen - "${#2}" ))
    return 0
}

# Returns print length of string, without counting CSI values.
#
# Args
#    (name):      name of variable in which the string length is returned
#    (string):    string for which the count is needed
string_len_sans_csi()
{
    local -n slscf_len="$1"
    local raw="$2"

    local c
    local in_esc=0
    local in_csi=0
    slscf_len=0
    while IFS= read -rn1 c && [ "$c" != $'\0' ]; do
        if (( in_csi )); then
            # CSI strings terminate with letter,
            # or ']' (linux private CSI sequences)
            # or '`' (HPA cursor placement instruction)
            if [[ "$c" =~ [\]\`[:alpha:]] ]]; then
                (( in_csi = in_esc = 0 ))
            fi
        elif (( in_esc )); then
            if [ "$c" == '[' ]; then
                in_csi=1
            else
                echo "Oops: escape followed by non-'[' character ($c)" >&2
                read -n1 -p "Press any key!"
                exit 1
            fi
        elif [ "$c" == $'\e' ]; then
            in_esc=1
        else
            (( ++slscf_len ));
        fi
    done <<< "$raw"

    return 0
}

# 'Echo's the first character that follows the first
# underscore in the string and returns TRUE (0).
# If there is no underscore+character in the string,
# the function returns FALSE (!0)
# Args
#    (string):    string in which the letter following an underscore
#                 is sought and echoed.
get_hilite_char()
{
    local str="$1"
    local -i pos
    if pos=$( strstrndx "$str" '_' ); then
        echo "${str:$((pos+1)):1}"
        return 0
    else
        return 1
    fi
}

# @def Output functions
# 
# Various simple functions making common needs to be convenient.

# Function to duplicate a character a given number of times
# Args
#    (integer):   number of characters to repeat
#    (character): character to be repeated
# shellcheck disable=2155  # ignore 'declare and assign separately' warning
dupchar()
{
    if [ "$1" -gt 0 ]; then
        local s=$( printf "%0${1}d" 0 )
        echo -n "${s//0/$2}"
    fi
}

# Print string with ESCAPE and NEWLINE characters replaced by \e and \n
#
# Args
#    (string):   keystroke string
print_keystroke()
{
    local keyp="${1///\\e}"
    keyp="${keyp///\\n}"
    keyp="${keyp//	/\\t}"
    echo -n "$keyp"
}

# Prints an array of text lines to a given location
#
# Args
#    (name):     name of simple array of text strings
#    (integer):  row at which to start printing
#    (integer):  column from which all text should print
indent_print()
{
    local -n ip_lines="$1"
    local -i row="$2"
    local -i col="$3"

    set_cursor_position "$row" "$col"

    for line in "${ip_lines[@]}"; do
        echo "$line"
        echo -n $'\e['"${col}G"
    done
}

# This variable can be changed in a calling script to set a different default.
# Consult `man console_colors` for color-setting instructions.
declare SS_HILITE_COLOR=$'\e[36;1m'

# Find and hilite substring in string (if found)
# Args
#    (name-out): string for the result
#    (string):   string to print
#    (string):   substring for which the color should be changed
#    (string):   optional color string to use when coloring the substring
#    (string):   optional unhilight color to use after hilighted part
hilite_substr_nameref()
{
    local -n hsn_output="$1"
    local str="$2"
    local substr="$3"
    local color_hl="${4:-$SS_HILITE_COLOR}"
    local color_off=$'\e[m'
    if [ "${#5}" -gt 0 ]; then color_off="$5"; fi
    local -i pos
    if pos=$( strstrndx "$str", "$substr" ); then
        local -i lensub="${#substr}"
        local -a parts=(
            "$color_off"
            "${str:0:$((pos))}"
            "$color_hl"
            "$substr"
            "$color_off"
            "${str:$((pos+lensub))}"
        )
        local OIFS="$IFS"
        local IFS=''
        hsn_output="${parts[*]}"
        local IFS="$OIFS"
    else
        hsn_output="$str"
    fi
}

# Find and hilite substring in string (if found)
# Args
#    (string):   string to print
#    (string):   substring for which the color should be changed
#    (string):   optional color string to use when coloring the substring
#    (string):   optional unhilight color to use after hilighted part
hilite_substr()
{
    local output
    hilite_substr_nameref "output" "$1" "$2" "$3" "$4"
    echo -n "$output"
}

# Hilights the character following the first ampersand in the stirng
# Default colors will be used unless alternates are provided.  The
# result will be store in the first argument, a nameref variable.
#
# Args
#    (name-out):  where result is stored
#    (string):    string to process
#    (string):    optional hilight color string
#    (string):    optional normal color string
#    (character): prefix character to recognize (default &)
hilite_prefixed_char()
{
    local -n hun_output="$1"
    local str="$2"
    local color_hl="${3:-$SS_HILITE_COLOR}"
    local color_off=$'\e[m'
    local prefix_char='&'
    if [ -n "$4" ]; then color_off="$4"; fi
    if [ -n "$5" ]; then prefix_char="${5:0:1}"; fi

    local -i strlen="${#str}"
    local -a parts=( "$color_off" )

    if pos=$( strstrndx "$str" "$prefix_char" ); then
        local left="${str:0:$pos}"
        local letter="${str:$(( ++pos )):1}"
        local right="${str:$(( ++pos ))}"
        parts+=(
            "$left"
            "$color_hl"
            "$letter"
            "$color_off"
            "$right"
        )
    else
        parts+=( "$str" )
    fi

    concat_array "hun_output" "parts"
}

# Hilights the character following the first amersand in the stirng
# Default colors will be used unless alternates are provided.  The
# result will be 'echo'ed to stdout.
#
# Args
#    (string):   string to process
#    (string):   optional hilight color string
#    (string):   optional normal color string
hilite_ampersand()
{
    local hu_output
    hilite_prefixed_char "hu_output" "$1" "$2" "$3"
    echo -n "$hu_output"
}


# Print a string, hilighting the character following the first
# ampersand, and adding optionally padding to a requested length.
# Args
#    (string):    string to print
#    (integer):   total characters to print, with spaces filling
#                 positions unfilled with the string.  Negative
#                 values will pad to the left.
#    (string):    optional ANSI hilite color string
#    (string):    ANSI normal color string.  Set this parameter
#                 if the color of the string is not the default
#                 text color.
hilite_pad()
{
    local str="$1"
    local -i pad="$2"

    local -i absolute_pad="${pad#-}"

    local str_no_amp="${str/&/}"
    local -i len_no_amp="${#str_no_amp}"
    local -i len_str="${#str}"

    # truncate before colors added
    if (( absolute_pad != 0 && len_nul > absolute_pad )); then
        str="${str:0:$absolute_pad}"
        absolute_pad=0
    fi

    local processed_str

    # if underscore exists
    if [ "$len_no_amp" -lt "$len_str" ]; then
        hilite_prefixed_char "processed_str" "$str" "$3" "$4"
    else
        processed_str="$str"
    fi

    if [ "$absolute_pad" -ne 0 ]; then
        if [ "$pad" -lt 0 ]; then
            dupchar $(( absolute_pad - len_no_amp )) ' '
            echo -n "$processed_str"
        else
            echo -n "$processed_str"
            dupchar $(( absolute_pad - len_no_amp )) ' '
        fi
    else
        echo -n "$processed_str"
    fi
}




# Prints string exactly the length of $2.
#
# Short strings are supplemented with extra spaces,
# long strings are truncated.
#
# Args
#    (string)   string to be printed
#    (integer)  number of characters to print
force_length()
{
    local str="$1"
    local -i len="$2"

    local -i needed=$(( len - "${#str}" ))
    if [ "$needed" -gt 0 ]; then
        str="$str"$( dupchar "$needed" " " )
    else
        str="${str:0:$len}"
    fi

    echo -n "$str"
}

# Prints CSI-encoded string at least at the length of $2.
#
# Short strings are supplemented with extra spaces,
# long strings ARE NOT truncated at this time.
#
# Args
#    (string)   string to be printed
#    (integer)  number of characters to print
force_length_csi()
{
    local str="$1"
    local -i len="$2"

    local -i csilen
    string_len_sans_csi "csilen" "$1"

    echo -n "$str"

    local -i needed=$(( len - csilen ))
    if [ "$needed" -gt 0 ]; then
        dupchar "$needed" ' '
    fi
}

# @def Paragraph formatting functions
#
# One function, bind_paragraphs(), scans text to group paragraphs,
# and another, format_paragraphs(), splits the bound paragraphs
# into length-limited lines.
#
# The functions are designed to work together to present a nicely
# formatted text display.
#
#    # create an array of paragraphs from a text file:
#    local -a paras
#    bind_paragraphs "paras" < "text.txt"
#
#    # convert the paragraphs into a length-constrained array of text lines:
#    local -a lines
#    format_paragraphs "lines" "paras" 60
#
#    # Directly print the lines, or use a 'block_text' script function:
#    block_text_display "lines"
#
#    This section also includes support function format_paragraph().  This
#    function is called by format_paragraphs() for each paragraph line and
#    is not meant for to be called directly.



# Parses text to make an array of single-line paragraphs.
#
# Consecutive text lines will be combined into a single line, when a text line
# is separated from its neighbor by an empty line (i.e. two consecutive newlines),
# the next line will start a new paragraph.
#
# Use this function to prepare text for formatting in function format_paragraphs().
#
# The input of the function is *stdin*.  One way to use it could be:
#    local -a PARAS=()
#    bind_paragraphs "PARAS" < "text.txt"
#
# or:
#    local -a PARAS=()
#    bind_paragraphs "PARAS" <<EOF
#    Sample Text, paragraph 1
#
#    Sample Text, paragraph 2
#    EOF
#
# Args
#    (name):     name of array in which the comiled lines should be stored.
bind_paragraphs()
{
    local -n output="$1"
    output=()

    local datext
    local -a lines=()
    local IFS=' '

    local -i lcount=0

    while IFS= read -r datext; do
        if [ -z "$datext" ]; then
            output+=( "${lines[*]}" )
            lines=()
        else
            lines+=( "$datext" )
        fi
    done

    output+=( "${lines[*]}" )
}

# Paragraph binder to process arrays of strings.
#
# Args
#    (name)   name of paragraphs array in which results are stored
#    (name)   name of array of strings to bind into paragraphs
bind_array_to_paragraphs()
{
    local -n batp_output="$1"
    local -n batp_input="$2"
    batp_output=()

    local -a paragraph=()
    local line
    local nospaces

    is_line_empty()       { [ "${#nospaces}" -eq 0 ]; }
    is_paragraph_empty()  { [ "${#paragraph[@]}" -eq 0 ]; }

    for line in "${batp_input[@]}"; do
        nospaces="${line// /}"

        # skip initial blank lines
        if is_line_empty; then
            if is_paragraph_empty; then
                continue
            else
                # Concatenate accumulated lines and save to output
                batp_output+=( "${paragraph[*]}" )
                paragraph=()
            fi
        else
            paragraph+=( "$line" )
        fi
    done

    if ! is_paragraph_empty; then
        batp_output+=( "${paragraph[*]}" )
    fi
}
# Splits a submitted string of words into as many lines as necessary
# to fit within the width constraints.
#
# Args
#    (name):        nameref of array to hold resulting lines
#    (string):      The line/paragraph to be printed
#    (integer):     Number of characters allowed per line
#    (integer):     Number of characters to indent the first line
#                   of a paragraph
format_paragraph()
{
    local IFS=' '

    local -n fp_lines="$1"
    local -a words=( $2 )
    local -i line_width="$3"
    local -i para_indent="$4"

    local indent
    indent=$( dupchar "$para_indent" ' ' )

    local word
    local -a line=( )
    local -i wordlen
    local -i linelen="$para_indent"

    fp_lines=()

    for word in "${words[@]}"; do
        string_len_sans_csi "wordlen" "$word"
        # wordlen="${#word}"
        if [ "${#indent}" -gt 0 ]; then
            line=( "${indent}$word" )
            (( linelen = para_indent + wordlen ))
            indent=""
        elif (( wordlen + linelen >= line_width )); then
            fp_lines+=( "${line[*]}" )
            line=( "$word" )
            (( linelen = wordlen ))
        else
            line+=( "$word" )
            (( linelen += wordlen + 1 ))
        fi
    done
    if [ "${#line[*]}" -gt 0 ]; then
        fp_lines+=( "${line[*]}" )
    fi
}

# Breaks paragraphs into an array of length-limited lines
#
# Args
#    (name):      name of array in which formatted lines will be returned
#    (name):      name of array in which source paragraphs will be read
#    (integer):   maximum line length for output lines
#    (integer):   number of characters to indent paragraphs.  If this value
#                 is 0 (or omitted), an empty line will indicate new
#                 paragraphs.  If this value is greated than 0, each
#                 paragraph will be indented this number of characters and
#                 the paragraphs will NOT be separated by empty lines.
format_paragraphs()
{
    local -n fps_output="$1"
    local -n fps_paras="$2"
    local -i width="$3"
    local -i para_indent="$4"

    fps_output=()

    local -a fps_lines
    local para
    local -i count=0
    for para in "${fps_paras[@]}"; do
        if (( count++ > 0 && para_indent == 0 )); then
            fps_output+=( "" )
        fi
        format_paragraph "fps_lines" "$para" "$width" "$para_indent"
        fps_output+=( "${fps_lines[@]}" )
    done
}


# @def Miscellaneous Stuff
#
# The following functions don't fit in neat categotries.

# Returns row count and maximum line length from a simple array
#
# Args
#    (name):    name of variable in which row count is returned
#    (name):    name of variable in which maximum line length is returned
#    (name):    name of simple array to be evaluated
get_string_array_extent()
{
    local -n gsae_rows="$1"
    local -n gsae_cols="$2"
    local -n gsae_lines="$3"

    gsae_rows="${#gsae_lines[@]}"
    gsae_cols=0

    local line
    local -i curlen
    for line in "${gsae_lines[@]}"; do
        curlen="${#line}"
        (( gsae_cols = ( curlen > gsae_cols ) ? curlen : gsae_cols ))
    done
}

# Searchs for a letter in a string, returning the index if found.
#
# The search begins at the position in nameref $1, and proceeds to
# start of the string when the end-of-string is encountered.
# If the string contains multiple instances of the letter, it
# will cycle between the instances.
#
# Args
#    (name-io):  starting index upon entry, found index on exit
#    (string):   haystack, string in which letters will be sought
#    (string):   char, actually.  The character to be sought.
#
# Unusual Return:
#   *true*  (0)  if letter found and it's a singleton, immediately open item
#   *false* (1)  if letter found, but there's another, OR
#                the letter was not found
progressive_letter_search()
{
    local -n pls_index="$1"
    local pls_haystack="$2"
    local pls_needle="$3"

    local current="${pls_haystack:$pls_index:1}"
    local right="${pls_haystack:$(( pls_index+1 ))}"
    local left="${pls_haystack:0:$pls_index}"
    local search="${right}${left}${current}"

    local -i ndx
    if strstrndx_nameref "ndx" "$search" "$pls_needle"; then
        local -i hcount="${#pls_haystack}"
        local -i lcount="${#left}"
        (( pls_index = ( ndx + lcount + 1 ) % hcount ))

        if ! strstrndx_nameref "ndx" "${search:$(( ndx+1 ))}" "$pls_needle"; then
            return 0
        fi
    fi

    return 1
}

# Returns row/column value to center a defined area
#
# Args
#    (name):    row value variable name
#    (name):    column value variable name
#    (name);    number of rows in region to be centered
#    (name);    number of columns in region to be centered
#    (name):    optional array name whose extent is to be used
#               for the rows and columns values
get_block_centering_values()
{
    local -n gcrc_row="$1"
    local -n gcrc_col="$2"
    local -n gcrc_rows="$3"
    local -n gcrc_cols="$4"

    if [ "$#" -gt 4 ]; then
        local -i lrows lcols
        get_string_array_extent "lrows" "lcols" "$5"

        (( gcrc_rows = ( gcrc_rows==0 ? lrows : gcrc_rows ) ))
        (( gcrc_cols = ( gcrc_cols==0 ? lcols : gcrc_cols ) ))
    fi

    local -i srows scols
    get_screen_size "srows" "scols"

    (( gcrc_row = ( srows - gcrc_rows ) / 2 ))
    (( gcrc_col = ( scols - gcrc_cols ) / 2 ))
}


# Get a year, month, and day value for a day of year value in a given year.
#
# Args
#    (name):    (in/out) name of integer variable where year value is read and returned
#    (name):    (out) name of integer month variable
#    (name):    (out) name of integer day variable
#    (integer): day of year value.  December 31 of previous year
date_from_day_of_year()
{
    local -n dfdoy_year="$1"
    local -n dfdoy_month="$2"
    local -n dfdoy_day="$3"
    local -i day_of_year="$4"

    local datestr="$dfdoy_year-01-01 + $day_of_year days - 1 day"
    local work=$( date -d "$datestr" +%F )
    local IFS='-'
    local -a dparts=( $work )
    dfdoy_year="10#${dparts[0]}"
    dfdoy_month="10#${dparts[1]}"
    dfdoy_day="10#${dparts[2]}"
}



# Get set or unset (-s or -u) for a shopt option.
#
# Use this function to preserve the state in order to
# restore it after a local shopt setting.
#
# Args
#    (string): shopt option to query
get_shopt_setting()
{
    local opt="$1"
    if [[ $( shopt -p "$opt" ) =~ -([us]) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi

    return 1
}

# Silently test if a builtin script function exists
#
# Rather than check for a version number or something else,
# it may be better to simply confirm that a function works.
#
# Args
#    (name):    name of builtin function to be sought
test_builtin() { help "$1" > /dev/null 2>&1; }

# Simple test for subshell.
#
# When using a nameref to return values to a calling function,
# the called function cannot be in a subshell or the changed
# value will be lost to the calling function.
#
# list_ui::lui_list_generic() uses this function to provide an early
# warning about this innocuous vulnerability.
in_subshell() { [ "$$" -ne "$BASHPID" ]; }


# @def Console state functions
#
# Use the following functions to prepare you application to
# gracefully recover from early termination, especially from
# the "echo" state that is might be turned off for some situations
# but would be inconvenient for the user if it were still off
# when back at the command line.

declare SS_STTY_STATE

# Save state and hide the cursor
save_console_state_hide_cursor()    { hide_cursor; SS_STTY_STATE=$( stty -g ); }

# Restore the state and start showing the cursor
restore_console_state_show_cursor() { show_cursor; stty "$SS_STTY_STATE"; }
