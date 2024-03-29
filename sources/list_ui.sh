# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# requires boxes, small_stuff, keypress, and block_text

# The contents of this file work with a _lui_list_.  A lui_list is
# an array of data organized as a mini table.  The first element of
# a lui_list is the column count, the number of elements per 'row'
# of the lui_list table.  The second element is the row count, and
# it should be set with the lui_list_init() function.

# shellcheck disable=SC2178
# shellcheck disable=SC2034   # disable unused variable warning for nameref variable _rc_

declare LUI_KEY_UP=$'\e[A'
declare LUI_KEY_DN=$'\e[B'
declare LUI_KEY_PGUP=$'\e[5~'
declare LUI_KEY_PGDN=$'\e[6~'

# @def lui_list
# 
# A lui_list is a specially-formatted array that is used in the
# list_ui script to deliver list-based user interface patterns on
# a console.
#
# A lui_list consists of a two-integer prefix, whose values are
# the number of columns and the number of rows, followed by the
# data elements.  The data elements will be interpreted as each
# consecutive set of _columns_ elements is a row.  For example,
# a two-column lui_list would look like this:
# 
# declare -a my_list=(
#    2                      # columns
#    0                      # rows (calculated later)
#    row1_name row1_value
#    row2_name row2_value
#    row3_name row3_value
# )
#
# See also: lui_list_validate() Checks the array overall length against the
#                               column count value.
#           lui_list_init()     Updates the _rows_ element based on the column
#                               count and the total number of array elements.
#           lui_list_convert()  Makes a lui_list from another array.



# Test list dimensions
# Compare assumed row and column count to total array elements
# to identify likely valid lui_list.
# 
# Args
#    (name):    name of a lui_list
#
# Returns
#    true (0)       likely valid lui_list
#    false (1)      invalid lui_list
lui_list_validate()
{
    local -n llv_list="$1"
    local -i full_count="${#llv_list[@]}"
    if [ "$full_count" -lt 2 ]; then
        return 1
    fi

    local -i colcount="${llv_list[0]}"
    local -i rowcount="${llv_list[1]}"

    (( ((colcount * rowcount) + 2 ) == full_count ))
}

# Tool to help discern why a lui_list might be invalid
lui_list_describe()
{
    local -n lld_list="$1"
    local -i full_count="${#lld_list[@]}"
    if [ "$full_count" -lt 3 ]; then
        echo "In '$1', too few ($full_count) elements to be a lui_list."
        return 1
    fi

    local -i colcount="${lld_list[0]}"
    local -i rowcount="${lld_list[1]}"

    echo "lui_list '$1' contains $full_count total elements,"
    echo "with $colcount columns in $rowcount rows."
}

# Debugging function that show contents of a lui_list
#
# Args:
#   (name):   name of lui_list
lui_list_dump()
{
    local -n lld_list="$1"
    local -i rsize="${lld_list[0]}"
    local -i ecount="${#lld_list[*]}"
    local -i ndx=0
    for (( ndx=0; (ndx+2)<ecount; ++ndx )); do
        if (( (ndx % rsize) == 0 )); then
            echo -n "------ "
            echo -n "record #$(( (ndx / rsize) + 1))"
            echo " ------"
        fi
        echo "  ${lld_list[$(( ndx+2 ))]}"
    done
}

# Checks and updates row count of properly-constructed lui_list.
# 
# Sets the row-count element (list[1]) by calculating the number
# of rows.  A suspicious element count (not evenly-dividable by
# the column count) triggers a warning and exit.
# 
# Args
#    (name):   name of a properly formatted list
lui_list_init()
{
    local -n luii_list="$1"
    if value_is_int "${luii_list[0]}" && value_is_int "${luii_list[1]}"; then
        local -i columns="${luii_list[0]}"

        local -i count_els="${#luii_list[@]}"
        if [ $(( (count_els - 2) % columns )) -ne 0 ]; then
            echo "corrupted list, bad elements ratio." >&2
            exit 1
        fi

        luii_list[1]=$(( ( count_els - 2 ) / columns ))
    else
        echo "Invalid dimension elements." >&2
        exit 1
    fi

    return 0
}

# Prepares properly-configured lui_list from a generic array.
#
# Submit an array to configure a properly-configured lui_list
# in the array named through argument 1.
#
# Args
#    (name):     array in which the derived lui_list will be written
#    (name):     array from which the lui_list will be created
#    (integer):  number of columns in the input array
#    (integer):  number of columns that should be in the output array
lui_list_convert()
{
    if [ "$1" == "$2" ]; then
        echo "Input and output lists must be different." >&2
        exit 1
    fi

    local -n llc_list_out="$1"
    local -n llc_list_in="$2"
    local -i in_cols="$3"
    local -i out_cols="$4"

    local -a extra_cols=()

    if [ "$out_cols" -gt "$in_cols" ]; then
        local -i i
        for (( i=0, limit=out_cols-in_cols; i<limit; ++i )); do
            extra_cols+=( 0 )
        done
    else
        out_cols="$in_cols"
    fi

    llc_list_out=( "$out_cols" 0 )
    local el
    local -a row=()
    local -i count=0
    for el in "${llc_list_in[@]}"; do
        row+=( "$el" )
        if [ "${#row[@]}" -eq "${in_cols}" ]; then
            (( ++count ))
            llc_list_out+=( "${row[@]}" "${extra_cols[@]}" )
            row=()
        fi
    done

    llc_list_out[1]="$count"
}

# @def list information functions
#
# This group of functions returns information about a lui_list

# Return column count value from lui_list
#
# Args
#    (name):    name of variable in which the result is returned
#    (name):    name of lui_list
lui_list_column_count() { local -n rc="$1"; local -n luil_list="$2"; rc="${luil_list[0]}"; }

# Return row count value from lui_list
#
# Args
#    (name):    name of variable in which the result is returned
#    (name):    name of lui_list
lui_list_row_count()    { local -n rc="$1"; local -n luil_list="$2"; rc="${luil_list[1]}"; }

# Test if requested row number exists in a lui_list
# 
# Args
#    (name):     name of lui list
#    (integer):  row number requested
#
# Returns true (0) if in range, non-zero if out of range
lui_list_row_in_range()
{
    local -n luii_list="$1"
    local -i requested_row="$2"
    local -i rows="${luii_list[1]}"

    [ "$requested_row" -ge 0 ] && [ "$requested_row" -lt "$rows" ]
}

# Sends successive rows to a callback function.  The callback function
# should return 0 (true) to continue, false (non-zero) to force early
# termination.
#
# Args
#    (name):   name of lui_list array
#    (name):   name of callback function. The callback function receives
#              $1    (integer):  the row number
#              $2... (various):  the fields of the current row
lui_list_iterate()
{
    local -i rows columns
    lui_list_row_count "rows" "$1"
    lui_list_column_count "columns" "$1"

    local -n luili_list="$1"
    local luili_callback="$2"

    for (( ndx=2, row=0; row<rows; ++row, ndx+=columns )); do
        if ! "$luili_callback" "$row" "${luili_list[@]:$ndx:$columns}"; then
            break
        fi
    done
}

# Determine the longest display length of a lui_list
#
# Args
#    (name-in):  name of a lui_list for nameref access
#    (name-in):  name of a gauge function that counts displayable characters,
#                the default function returns the max length of the first
#                field in the lui_list.
#
#                The gauge function should accept the following arguments:
#                $1    (name):    name of integer value in which the count is returned
#                $2... (various): the fields of the current row
lui_list_max_len()
{
    local list_name="$1"
    local gauge_func="${2:-lui_list_line_length_column}"

    local -i limit maxlen=0

    # "closure" function that accesses a variable of the outer function (maxlen)
    llml_calc()
    {
        # ignore the row number for this purpose
        local -a row
        row=( "${@:2}" )

        local -i len
        "$gauge_func" "len" "${row[@]}"
        if (( len > maxlen )); then
            (( maxlen = len ))
        fi

        return 0
    }

    lui_list_iterate "$list_name" "llml_calc"

    echo "$maxlen"
}

# @def Key Action List Construction Functions
#
# Simplify construction of compilcated lists.  Functions in this
# section build useful key action lists from simpler hinted
# data.

# Returns array of underscore-hilited letters from array of strings.
# 
# Args
#    (name):    name of array where result will be placed
#    (name):    name of array of strings from which the letters
#               will be harvested
#    (integer): capitalization flag.  Default (0) is to save upper-case
#               letters as lower-case options.  Non-zero values will preserve
#               letters' cases to differentiate, for example, 'f' from 'F'.
lui_list_build_letter_array()
{
    local -n llbla_letters="$1"
    local -n llbla_entries="$2"
    local -i allow_capitals="$3"

    llbla_letters=()

    local entry
    for entry in "${llbla_entries[@]}"; do
        letter=$( get_hilite_char "$entry" )
        if [ "$allow_capitals" -eq 0 ]; then
            letter="${letter,,?}"
        fi
        llbla_letters+=( "$letter" )
    done
}

# @def list row action functions
#
# Access the lui_list contents with row action functions.
# The 'get' function is lui_list_copy_row(), and
# the 'put' function is lui_list_replace_row().
#
# Despite having the same parameters, the parameter order
# is different for the two functions in order to maintain
# the library convention of keeping changing parameters
# leftmost.


# Get a row from a lui_list array.  Returns 0 (true) if the row
# was successfully returned, non-zero (false) if out-of-range and
# no row data is being returned.
# 
# Args
#    (name):     name of array in which the row is to be copied
#    (name):     name of lui_list array
#    (integer):  row number to be returned
lui_list_copy_row()
{
    if lui_list_row_in_range "$2" "$3"; then
        local -n target_row="$1"
        local -n luii_list="$2"
        local -i requested_row="$3"

        local -i columns="${luii_list[0]}"
        local -i rows="${luii_list[1]}"

        local -i ndx=$(( 2 + ( requested_row * columns ) ))
        target_row=( "${luii_list[@]:$ndx:$columns}" )
        return 0
    else
        echo "requested_row $3 is an out-of-range copy value for list '$2'" >&2
    fi

    return 1
}

# Get a row from a lui_list array.  Returns 0 (true) if the row
# was successfully returned, non-zero (false) if out-of-range and
# no row data is being returned.
# 
# Args
#    (name):     name of lui_list array
#    (name):     name of array from which the row is to be copied
#    (integer):  row number to be replaced
lui_list_replace_row()
{
    local list_name="$1"
    local -n source_row="$2"
    local -i target_row_num="$3"

    local -n luii_list="$list_name"

    if lui_list_row_in_range "$1" "$3"; then
        local -i columns="${luii_list[0]}"
        local -i rows="${luii_list[1]}"

        local -i ndx=$(( 2 + ( target_row_num * columns ) ))
        local -i i
        for (( i=0; i<columns; ++i )); do
            luii_list[$(( ndx + i ))]="${source_row[$i]}"
        done
        return 0
    else
        echo "requested_row $3 is an out-of-range replace value for list '$2'" >&2
    fi

    return 1
}

# Add a row to an existing lui_list.
#
# Mismatches between the column count of the lui_list and the new
# row will be done by adding (empty) or ignoring extra columns to
# maintain the integrity of the target lui_list.
#
# Args
#    (name):    name of lui_list into which the row will be appended
#    (name):    name of row array that will be appended to the lui_list
lui_list_append_row()
{
    local list_name="$1"
    local -n source_row="$2"

    local -n llar_list="$list_name"

    local -i list_cols
    lui_list_column_count "list_cols" "$list_name"
    local -i row_cols="${#source_row[@]}"
    local -a new_row=()

    if lui_list_validate "$list_name"; then
        if [ "$row_cols" -ge "$list_cols" ]; then
            new_row=( "${source_row[@]:0:$list_cols}" )
        else
            new_row=( "${source_row[@]}" )
            for (( ndx=row_cols; ndx<list_cols; ++ndx )); do
                new_row+=( "" )
            done
        fi
        llar_list+=( "${new_row[@]}" )
        (( ++llar_list[1] ))
    else
        echo "Invalid lui_list: not able to append."
        exit 1
    fi
}

# Returns (echo) the direct array index to a given row and column.
#
# This function permits direct access to a specific cell for
# reading and writing.  For many operations, this is a
# high-performance alternative to lui_list_copy_row() followed
# by lui_list_replace_row().
#
#   declare -i ndx
#   if ndx=$( lui_list_ndx_from_row_cell 'list_name' 2 4 ); then
#     echo "Retrieved cell: ${the_list[$ndx]}."
#     the_list[$ndx]="new value"
#   fi
#
# Args
#    (name):    name of lui_list
#    (integer): row number of target cell
#    (integer): cell number of target cell
#
# Returns TRUE (0) if requested cell in range, FALSE (1) otherwise.
lui_list_ndx_from_row_cell()
{
    local -n llg_list="$1"
    local -i row="$2"
    local -i cell="$3"

    local -i rows="${llg_list[1]}"
    local -i cols="${llg_list[0]}"

    local -i ndx=$(( 2 + (row * cols) + cell ))

    if [ "$ndx" -ge 0 ] && [ "$ndx" -lt "${#llg_list[@]}" ]; then
        echo "$ndx"
        return 0
    else
        echo "-1"
        return 1
    fi
}

# Calculate the index of the beginning of a given row
#
# Args
#    (name-out):  name of integer variable in which the result is returned
#    (name-in):   name of the lui_list from which the row will be read
#    (integer):   row of interest
#    (integer):   cell of interest
lui_list_ndx_from_row_cell_nameref()
{
    local ndx_name="$1"
    local list_name="$2"
    local -i row="$3"
    local -i cell="$4"

    local -n llnf_ndx="$ndx_name"
    local -n llnf_list="$list_name"
    local -i cols="${llnf_list[0]}"
    local -i els="${#llnf_list[@]}"

    local -i loc_ndx=$(( 2 + (row * cols) + cell ))

    if (( loc_ndx >= 2 && loc_ndx < els )); then
        llnf_ndx="$loc_ndx"
        return 0
    fi

    llnf_ndx=-1
    return 1
}

# Directly set an element by row/cell
lui_list_set_row_cell()
{
    local -n lls_list="$1"
    local -i row="$2"
    local -i cell="$3"
    local value="$4"

    local -i ndx

    if lui_list_ndx_from_row_cell "$1" "$2" "$3"; then
        lls_list["$ndx"]="$value"
    else
        echo "Implied cell described by $row/$cell is out of range." >&2
        exit 1
    fi
}

# @def line_length functions
#
# These functions are called by lui_list_max_len() to get the number of
# displayed characters for a list line.  lui_list_max_len() compares each
# row in a lui_list to find the largest line length value to the nameref
# first argument.
#
# These functions takes the following parameters:
# 1. The nameref of an integer variable in which the length is returned.
# 2. The first column of the current row,
# ...followed by the rest of the columns of the current row.
#
# It should return 0 (success).  lui_list_max_len() uses lui_list_iterate(),
# which stops sending rows if a function returns non-zero (error).
#
# There are two built-in line_length functions:
# 1. lui_list_line_length_column() returns the length of the first column
# 2. lui_list_line_length_selection() accounts for '[ ]' in radio or
#    checkbox interactions.

# default line_length function function for lui_list_max_len()
#
# Returns the raw length of the first column of the given row.
#
# Args
#    (name):        nameref of integer in which the length is stored
#    (various):     columns of current row
lui_list_line_length_column()
{
    local -n llllc_len="$1"
    shift
    llllc_len="${#1}"
    return 0
}

# line_length function function for determining radio and checkbok display line length.
#
# This simply adds 4 to the length of the first column, accounting for
# the prepended string '[x]' or '[ ]' for selection rows.
# 
# Args
#    (name):        nameref of integer in which the length is stored
#    (various):     columns of current row
lui_list_line_length_selection()
{
    local -n lllls_len="$1"
    shift
    lllls_len="${#1}"
    (( lllls_len += 3 ))
    return 0
}

# @def line display functions
# 
# The lui_list_generic() requires a line display function.
# The line display function is called by lui_list_generic with three
# arguments for each line displayed on the screen:
# $1 (integer)    A flag parameter.  A non-zero value indicates that the
#                 row being displayed is the row on which any action will
#                 be taken, whether selection, toggle, or action.
# $2 (integer)    A padding value. It is the length of the longest of
#                 the first column elements, and can be used to ensure
#                 all list elements are the same length.
# ${@:3}          Parameters $3 and beyond are the elements of the
#                 selected row which can be used to 
#
# There are several built-in display line functions:
#   lui_list_display_line()            for simple strings
#   lui_list_menu_display_line()       hilites the character following an
#                                      underscore for menus
#   lui_list_selectable_display_line() for selectable lines, which are
#                                      prefaced with [x] or [ ], depending
#                                      on whether or not the line is flagged
#                                      as selected.
#
#  Study them to better understand how line display functions work.

# Model, minimal, default line displayer function.
#
# This function is called by lui_list_generic() for each line
# that is to be displayed.  It is expected that developers will
# create custom versions of this function for specific uses.
#
# The first argument is a flag indicating that the current row
# is the selected row.
#
# Args
#    (integer)     indicated flag, non-zero if active, zero if inactive
#    (integer)     minimum number of characters per line
#    (various...)  all elements of current row follow the second argument
lui_list_display_line()
{
    local -i hilite="$1"
    local -i padding="$2"

    # Shift to make function parameters positions match row elements
    shift 2

    if [ "$hilite" -ne 0 ]; then
        echo -n $'\e[44m'
    fi
    force_length "$1" "$padding"
    echo $'\e[m'
}

# Line displayer that hilites letter following an underscore.
#
# This function is called by lui_list_generic() for each line
# that is to be displayed.  It is expected that developers will
# create custom versions of this function for specific uses.
#
# The first argument is a flag indicating that the current row
# is the selected row.
#
# Args
#    (integer)     indicated flag, non-zero if active, zero if inactive
#    (integer)     minimum number of characters per line
#    (various...)  all elements of current row follow the second argument
lui_list_menu_display_line()
{
    local -i hilite="$1"
    local -i padding="$2"

    if [ "$hilite" -ne 0 ]; then
        echo -n $'\e[44m'
    fi

    hilite_pad "$3" "$padding"
    echo $'\e[m'
}

# Model, minimal, default selectable line displayer
#
# This function is used by the built-in radio and checkbox
# dialogs derived from an appropriate lui_list.
#
# Args
#    (integer)     indicated flag, non-zero if active, zero if inactive
#    (integer)     minimum number of characters per line
#    (various...)  all elements of current row follow the second argument
lui_list_display_selectable_line()
{
    local -i hilite="$1"
    local -i padding="$2"

    # Shift to make function parameters positions match row elements
    shift 2

    local entry="$1"
    local -i len_entry="${#entry}"
    local -i spaces_needed=$(( padding - ( 3 + len_entry ) ))

    if [ "$hilite" -ne 0 ]; then echo -n $'\e[43m'; fi

    if [ "$2" -eq 0 ]; then
        echo -n '[ ]'
    else
        echo -n '[x]'
    fi

    if (( spaces_needed < 0 )); then
       local -i cutlen=$(( len_entry + spaces_needed ))
       echo -n "${entry:0:$cutlen}"
    else
        echo -n "$entry"
        dupchar "$spaces_needed" ' '
    fi
    echo $'\e[m'
}

# @def key actions
#
# A key action entry indicates what function to call if one of a set
# of keys is pressed.  The key action entry may optionally include a
# short description of key action's purpose for generating an key
# action.  Here are some key action entry examples:
#
# (ESCAPE or 'q' to quit)
# $'\e|q:LUI_ABORT:Terminate current context'
#
# (F1 or '?' to display help)
# $'\eOP|?:show_help:Show help display'
#
# Colons (':') separate the three key action elements, which are
# a key list, a function name, and an optional help string.
#
# The key list may contain multiple keystrokes separated by the pipe
# character ('|').  Non-printable keys are often represented by
# multi-character strings, like '\e[A' for the up arrow key or '\eOP'
# for the F1 key.  You can use the script `keypress_test` to find
# other keystroke strings.
#
# A key action list is an array of key action entries.  The central
# function of this script, lui_list_generic(), calls lui_list_process_key()
# with a key action list to respond to user key presses.  Preparing a
# custom key action list for lui_list_generic() allows a developer to
# create useful Bash applications.
#
# Refer to 'key action functions' for details about how key action list
# functions are called.

# @def key processing functions
#
# This script gets user input through the keyboard, and this group of
# functions converts user keystrokes into action, from scrolling the
# contents to acting on selection.
#
# There is one fixed-key processing function, lui_list_key_move_selection(),
# which handles moving the selection in response to arrow or page keys.
#
# The second key processing function, lui_list_process_key(), handles
# developer-designed key responses, triggering function calls as a
# response to designated keystrokes.

# Processes movement keypresses for lui_list_generic().
#
# If the keypress an arrow or page movement key, this function will
# determine which item is to be selected, the value of which is
# echo-ed to the calling function.  The return value is 0 (true)
# if the user has typed a recognized key, so the calling function
# knows if the user made a move.
#
# Args
#    (name):     name of integer value in which the new selection will be stored
#    (string):   string representing a keypress
#    (integer):  index of currently-selected list element
#    (integer):  index of top/first element displayed on screen
#    (integer):  maximum number of lines to display
#    (integer):  number of elements in the lui_list
lui_list_key_move_selection()
{
    local -n llkms_new_selection="$1"
    local keyp="$2"
    local -i selected="$3"
    local -i top_row="$4"
    local -i line_count="$5"
    local -i row_count="$6"

    local -i bottom_row=$(( top_row + line_count - 1 ))
    local -i matched=0

    case "$keyp" in
        "$LUI_KEY_DN" )
            (( ++selected, ++matched ))
            if [ "$selected" -ge "$row_count"  ]; then
                selected=$(( row_count-1 ))
            fi
            ;;
        "$LUI_KEY_UP" )
            (( --selected, ++matched ))
            if [ "$selected" -lt 0 ]; then
                selected=0
            fi
            ;;
        "$LUI_KEY_PGUP" )
            (( ++matched ))
            if [ "$selected" -eq "$top_row" ]; then
                selected=$(( selected - line_count ))
            else
                selected="$top_row"
            fi
            if [ "$selected" -lt 0 ]; then
                selected=0
            fi
            ;;
        "$LUI_KEY_PGDN" )
            (( ++matched ))
            if [ "$selected" -eq "$bottom_row" ]; then
                selected=$(( selected + line_count ))
            else
                selected="$bottom_row"
            fi
            if [ "$selected" -ge "$row_count" ]; then
                selected=$(( row_count - 1 ))
            fi
            ;;
    esac

    llkms_new_selection="$selected"
    [ "$matched" -gt 0 ]
}

# Finds and executes a key action entry that matches a keystroke.
#
# Look at the key actions section to learn about key actions and
# how to use them.
#
# Args
#    (string):     string representation of a keypress
#    (name):       name of a key array
#    (name):       name of lui_list in use
#    (integer):    index into the lui_list of the indicated item
#    (various):    extra arguments passed to lui_list_generic(),
#                  that is $6 and above
#
# Returns 0 if no key matched, 1 to terminate 
lui_list_process_key()
{
    local keyp="$1"
    local -n key_arr="$2"
    local list_name="$3"
    local -i row_number="$4"
    local -a extra_args=( "${@:5}" )

    local OIFS="$IFS"

    local -a entry keys
    local k IFS key cmd

    # shellcheck disable=SC2206  # don't warn for unquoted variable array initialization
    for k in "${key_arr[@]}"; do
        IFS=':'; entry=( $k )
        IFS="|"; keys=( ${entry[0]} )
        cmd="${entry[1]}"
        IFS="$OIFS"

        for key in "${keys[@]}"; do
            if [ "$key" == "$keyp" ]; then
                "$cmd" "$keyp" "$list_name" "$row_number" "${extra_args[@]}"
                return "$?"
            fi
        done
    done

    # zero return value means that we didn't match the key
    return 0
}



declare -a LUI_DEFAULT_TERM_KEYS=(
    $'\e|q:LUI_ABORT:Quit immediately'
    $'\n:LUI_SELECT:Save and Quit'
)

# @def key action functions
#
# When running lui_list_generic(), user keypresses are processed through
# lui_list_process_key(), which attempts to find a matching key action entry
# (refer to the `key actions` topic).  If the keystroke is matched, the
# key action function is called to execute the developer's intention.
#
# lui_list_process_key() will call a key action function with the following
# parameters:
#
# $1 (string)          A character string representing the keypress that
#                      triggers this action
# $2 (name)            name of a lui_list that can be applied to a nameref
#                      variable to get access to the controlling lui_list.
# $3 (integer)         row number of the currently indicated row
# ${@:3} (various...)  optional extra parameters passed to lui_list_generic()
#                      following the first five parameters.
#
# The return value is unusual.  The following return values are significant:
#   0    the interaction continues
#   1    the interaction terminates with user aborting (ie ESC or 'q')
#   2    the interaction terminates with user mandate  (ie ENTER or space)
#   3    the interaction continues with full replot
#   >3   custom usage/response (not sure yet how to trigger custom response, tho)
#
# Example row action functions are:
#   LUI_ABORT
#   LUI_SELECT
#   lui_list_action_radio_select
#   lui_list_action_checkbox_select

# Built-in term-keys function for ESC or 'q'
LUI_ABORT()  { return 1; }
# Built-in term-keys function for 'ENTER'
LUI_SELECT() { return 2; }

# Built-in key action function handling radio selection.
#
# Item selection toggles the state of the indicated line and clears the
# states of all other items.
#
# Args
#    (string)      A character string representing the keypress that
#                  triggers this action
#    (name)        name of the current lui_list
#    (integer)     row number of the currently indicated lui_list row
#    (various...)  optional extra parameters passed to lui_list_generic()
#                  following the first five parameters.
#
# Returns 0 to continue the interaction
lui_list_action_radio_select()
{
    local keyp="$1"
    local list_name="$2"
    local -i row_ndx="$3"
    local -a extra=( "${@:3}" )

    local -n llar_list="$list_name"
    local -i row_count="${llar_list[1]}"
    local -a row
    for ((ndx=0; ndx < row_count; ++ndx )); do
        if lui_list_copy_row "row" "$list_name" "$ndx"; then
            if [ "$ndx" -eq "$row_ndx" ]; then
                (( row[1] = (row[1] + 1 ) % 2 ))
                lui_list_replace_row "$list_name" "row" "$ndx"
            elif [ "${row[1]}" -ne 0 ]; then
                (( row[1] = 0 ))
                lui_list_replace_row "$list_name" "row" "$ndx"
            fi
        else
            echo "radio select row out-of-range" >&2
            exit 1
        fi
    done

    return 0
}

# Built-in key action function handling checkbox selection.
#
# Item selection toggles the state of the indicated line and leaves
# the states of all other items unchanged.
#
# Args
#    (string)      A character string representing the keypress that
#                  triggers this action
#    (name)        name of the current lui_list
#    (integer)     row number of the currently indicated lui_list row
#    (various...)  optional extra parameters passed to lui_list_generic()
#                  following the first five parameters.
#
# Returns 0 to continue the interaction
lui_list_action_checkbox_select()
{
    local keyp="$1"
    local list_name="$2"
    local -i row_ndx="$3"
    local -a extra=( "${@:3}" )

    local -a row
    if lui_list_copy_row "row" "$list_name" "$row_ndx"; then
        (( row[1] = (row[1] + 1 ) % 2 ))
        lui_list_replace_row "$list_name" "row" "$row_ndx"
    else
        echo "radio select row out-of-range" >&2
        exit 1
    fi

    return 0
}

# @def key action self-documentation support
#
# In the interest of providing information to the user, this set of
# functions use the key actions in the key action list to generate
# a usable help page.

# Translate non-typeable keystroke strings to the triggering key.
#
# Args
#    (string):    keystroke string from get_keypress (in keypress script)
lui_list_name_key()
{
    local keyp="$1"
    local name=""
    local letter
    local -i numeral
    case "$keyp" in
        $' '      ) name="SPACE"  ;;
        $'\n'     ) name="ENTER"  ;;
        $'\e'     ) name="ESCAPE" ;;
        $'\eOP'   ) name="F1"     ;;
        $'\eOQ'   ) name="F2"     ;;
        $'\eOR'   ) name="F3"     ;;
        $'\eOS'   ) name="F4"     ;;
        $'\e[15~' ) name="F5"     ;;
        $'\e[17~' ) name="F6"     ;;
        $'\e[18~' ) name="F7"     ;;
        $'\e[19~' ) name="F9"     ;;
        $'\e[H'   ) name="HOME"   ;;
        $'\e[F'   ) name="END"    ;;
        $'\e[2~'  ) name="INSERT" ;;
        $'\e[3~'  ) name="DELETE" ;;
        $'\t'     ) name="TAB"    ;;
        $'\eOp'   ) name="F1"     ;;
        $'\eOq'   ) name="F2"     ;;
        $'\eOr'   ) name="F3"     ;;
        $'\eOs'   ) name="F4"     ;;
        * )
            if [ "${#keyp}" -eq 1 ]; then
                name="$keyp"
            else
                name="${keyp///\\e}"
            fi
            ;;
    esac
    echo -n "$name"
}

# Writes a list of keys for lui_list_display_keys_helps
#
# Args
#   (string):   the keys list element of a line from a keylist array
lui_list_list_keys()
{
    local OIFS="$IFS"
    local IFS='|'
    local -a keys=( $1 )
    IFS="$OIFS"

    local key
    local comma=0
    for key in "${keys[@]}"; do
        if [ "$comma" -gt 0 ]; then
            echo -n ", "
        else
            (( ++comma ))
        fi

        lui_list_name_key "$key"
    done
}

# Create a lui_list of translated keys and action descriptions
#
# The returned values from this function provides information to make
# a formatted user hints display.  The compiled information will
# enable lui_list_display_keys_help() to generate as useful help
# page from the key actions list.
#
# Args
#    (name):     name of lui_list array in which the output will be written
#    (name):     name of integer in which max key string length will be set
#    (name):     name of integer in which max action string length will be set
#    (name):     name of keylist array of actions from which info will be taken
lui_list_key_advice_list()
{
    local infolist_name="$1"
    local -n llka_max_key="$2"
    local -n llka_max_act="$3"
    local keylist_name="$4"

    local -n llka_infolist="$infolist_name"
    local -n llka_keylist="$keylist_name"

    # initialise output lui_list to empty, 2-column list
    llka_infolist=( 2 0 )

    llka_max_key=0
    llka_max_act=0
    local -i cur_key cur_act

    local keyline
    local -a keydec newrow
    local keytext acttext

    local IFS OIFS="$IFS"

    for keyline in "${llka_keylist[@]}"; do
        IFS=":"
        keydec=( $keyline )
        IFS="$OIFS"
        if [ "${#keydec[@]}" -gt 2 ]; then
            keytext=$( lui_list_list_keys "${keydec[0]}" )
            cur_key="${#keytext}"
            acttext="${keydec[2]}"
            cur_act="${#acttext}"

            newrow=( "$keytext" "$acttext" )

            (( llka_max_key = ( cur_key > llka_max_key ) ? cur_key : llka_max_key ))
            (( llka_max_act = ( cur_act > llka_max_act ) ? cur_act : llka_max_act ))

            lui_list_append_row "$infolist_name" "newrow"
        fi
    done
}

# Presents an explanation of available keys.
#
# Args
#    (name):    name of the current keylist array
lui_list_display_keys_help()
{
    local keylist_name="$1"

    local -a infolist
    local -i maxkey maxact

    lui_list_key_advice_list "infolist" "maxkey" "maxact" "$keylist_name"
    local llak_format="%${maxkey}s: %-${maxact}s"

    local -a blocktext=(
        "Currently Active Keys"
        ""
        "Up and Down arrow keys and PgUp and PgDn keys"
        "work as expected."
        ""
    )

    # Process all rows to make block text:
    line_adder()
    {
        local line
        printf -v line "$llak_format" "$2" "$3"
        blocktext+=( "$line" )
    }
    lui_list_iterate "infolist" "line_adder"

    block_text_display "blocktext"

    return 0
}



# @def lui_list display functions
#
# There are several functions that manage the display and navigation
# of a lui_list.


# Plot the contents of a text array at the given location
#
# The text array will be written without any processing; it should
# have been previously formatted to fit.
#
# Look at small_stuff::format_paragraphs
#
# Args
#    (name):     name of text array
#    (integer):  row at which to start printing text
#    (integer):  column at which to start printing text
lui_list_plot_head()
{
    local -n text_lines="$1"
    local -i row="$2"
    local -i column="$3"
    local line

    set_cursor_position "$row" "$column"
    for line in "${text_lines[@]}"; do
        echo "$line"
    done
}


# Used by lui_list_generic() to discern the top/first display row.
#
# Args
#    (name):       (in/out) name of "top_row" integer variable
#    (integer):    index in full list of currently selected item
#    (integer):    maximum number of items displayed on screen
lui_list_calc_top_row()
{
    local -n llctr_top_row="$1"
    local -i selected="$2"
    local -i line_count="$3"
    if [ "$selected" -lt "$llctr_top_row" ]; then
        (( llctr_top_row = selected ))
    elif [ "$selected" -gt $(( llctr_top_row + line_count - 1 )) ]; then
        (( llctr_top_row = selected - line_count + 1 ))
    fi
}

# Determine the safest content width.
#
# First get largest of requested width and content width, then
# reduce to fit in screen if necessary.  Returns the calculated
# width in a nameref variable of $1.
#
# Args
#    (name):    name of integer variable in which to store result
#    (name):    name of lui_list from which the list is printed
#    (integer): requested width
lui_list_calc_suitable_width()
{
    local -n best_width="$1"
    local list_name="$2"
    local -i llcsw_cols="$3"

    # Get largest of requests
    local -i maxlen=$( lui_list_max_len "$list_name" "lui_list_line_length_selection" )
    (( llcsw_cols = ( llcsw_cols==0 || maxlen > llcsw_cols ? maxlen : llcsw_cols ) ))

    # possibly constrain width by screen width
    local -i srows scols
    get_screen_size "srows" "scols"
    (( best_width = ( llcsw_cols > scols  ? scols : llcsw_cols ) ))
}

# Display a screen-full of list items.
#
# This function prints out a screenful of item lines based on various
# list and index metrics.
#
# Args
#    (name):      name of lui_list that provides content for display
#    (integer):   index of first item to display (top_row)
#    (integer):   index of selected item
#    (integer):   row to begin writing
#    (integer):   column to begin writing
#    (integer):   number of lines to display
#    (integer):   number of characters to print per item
#    (name):      name of function that should be used to display lines
lui_list_show_lines()
{
    local lui_list_name="$1"
    local -i top_row="$2"
    local -i selected="$3"
    local -i row="$4"
    local -i col="$5"
    local -i line_count="$6"
    local -i width="${7:-0}"
    local line_displayer="$8"

    local -a row_vals
    local -i count=0
    local -i row_ndx="$top_row"
    local -i hilited

    set_cursor_position "$row" "$col"
    for (( ; count < line_count; ++count, ++row_ndx )); do
        row_vals=()
        if [ "$row_ndx" -lt "$row_count" ]; then

            # Convert boolean result to integer for use by line_displayer:
            [ "$row_ndx" -ne "$selected" ]
            hilited="$?"

            lui_list_copy_row "row_vals" "$lui_list_name" "$row_ndx"
            "$line_displayer" "$hilited" "$width" "${row_vals[@]}"
            echo -n $'\e['"${col}G"   # move to proper cursor position
        else
            hilite_pad " " "$width"
            echo
        fi
    done
}

# Displays a warning if lui_list_generic() is called in a subshell.
#
# The lui_list_generic() calls get_screen_size(), which fails in a
# subshell.  Without get_screen_size(), lui_list_generic() can't
# validate the output size.
lui_list_subshell_warning()
{
    local name=$'\e[32;1m'
    local err=$'\e[31;1m'
    local end=$'\e[m'

    local -a paras
    bind_paragraphs 'paras' <<EOF

${name}lui_list_generic()${end} calls ${name}get_screen_size()${end},
which cannot work in a subshell.  Press any key to continue.
EOF

    local -a lines
    format_paragraphs "lines" "paras" 60

    local line
    for line in "${lines[@]}"; do
        echo "$line" >&2
    done

    read -n1
}

# @def Debugging Aids
#
# There isn't much here at the start except for a function to
# test parameters submitted to lui_list_generic().  Since all
# interactions pass through lui_list_generic(), it's a good place
# to test.

named_var_is_lui_list()
{
    if named_var_is_array "$1"; then
        if lui_list_validate "$1"; then
            return 0
        else
            echo "Variable name '$1' is not a lui_list." >&2
        fi
    else
        echo "Variable '$1' is not an array." >&2
    fi

    return 1
}

# Test lui_list_generic function arguments.
#
# Do some sanity checking for several of the arguments, particularly
# ensuring that names of lui_lists and arrays exist and are valid.
#
# Args:  see argument list from lui_list_generic()...
lui_list_confirm_arguments()
{
    local -i count=0
    if [ -n "$1" ] && ! named_var_is_int "$1"; then
        (( ++count ))
        echo "Parameter 1 ($1) must be an integer" >&2
    fi
    if ! named_var_is_lui_list "$2"; then
        (( ++count ))
        echo "Parameter 2 ($2) must be a lui_list." >&2
    fi
    if [ -n "$7" ] && ! named_var_is_function "$7"; then
        (( ++count ))
        echo "Parameter 7 ($2) must be a function." >&2
    fi
    if [ -n "$8" ] && ! named_var_is_array "$8"; then
        (( ++count ))
        echo "Parameter 8 ($8) must be a keys array." >&2
    fi
    if [ -n "$9" ] && ! named_var_is_array "$9"; then
        (( ++count ))
        echo "Parameter 9 ($9) must be a paragraphs array." >&2
    fi

    [ "$count" -eq 0 ]
}


# @def primary list interaction
#
# The function lui_list_generic() is the simple and flexible consolidation
# of the list display, navigation, and general keypress functions described
# above.  Other interactions will call lui_list_generic() with custom
# line display functions and key action lists.

# Creates lui_list-based UI widgets
#
# Nearly any list-based user interaction can be build using this function
# by providing custom line display and key list definitions.
#
# NOTE: With a warning, this function refuses to run in a subshell.  Please
#       design your usage to prevent running in a subshell.
#
# Args
#    (name):       optional name of integer variable in which the selected index
#                  can be read
#    (name):       name of lui_list from which the widget will be constructed
#    (integer):    row on which to start printing the list.  Set to 0 for a
#                  display centered vertically.
#    (integer):    column on which to start printing the list.  Set to 0 for a
#                  display centered horizontally.
#    (integer):    size of list in lines.  Will be constrained to screen height
#                  if the value is too large.
#    (integer):    width of list in characters.  Will be constrained to screen
#                  width if the value is too large.
#    (name):       optional name of function that will display summary lines
#    (name):       optional name of keystroke functions list
#    (name):       optional name of paragraphs array to print above the list
#    (various...): Optional extra arguments that will be passed to keystroke functions.
#                  These extra arguments can be exploited by custom widgets.
lui_list_generic()
{
    # Don't continue if in subshell
    if in_subshell; then
        lui_list_subshell_warning
        exit 1
    fi

    if ! lui_list_confirm_arguments "$@"; then
        echo "lui_list_generic argument type error." >&2
        exit 1
    fi

    local -i bogus=0
    # shellcheck disable=SC2155
    local -n llg_selected="${1:-bogus}"
    local lui_list_name="$2"
    local -i row="${3:-0}"
    local -i col="${4:-0}"
    local -i line_count="$5"
    local -i chars_width="${6:-40}"
    local line_displayer="${7:-lui_list_display_line}"
    local term_keys_list_name="${8:-LUI_DEFAULT_TERM_KEYS}"
    local head_array_name="$9"

    local -a extra_args
    if [ "$#" -gt 9 ]; then
        extra_args=( "${@:10}" )
    fi

    local -i row_count
    lui_list_row_count "row_count" "$lui_list_name"

    # Use row count as line_count if line_count not defined (==0)
    if [ "$line_count" -eq 0 ]; then
        line_count="$row_count"
    fi

    # No choice to be made if fewer than 2 choices
    if [ "$line_count" -lt 2 ]; then
        echo "Invalid line count: $line_count" >&2
        exit 1
    fi

    # Account for head lines when adjusting the line_count
    local -a head_text=()
    local -i head_lines=0
    local -i plot_head=0
    if [ "$head_array_name" ]; then
        colorize_array "$head_array_name"
        format_paragraphs "head_text" "$head_array_name" "$chars_width" 0
        (( head_lines = "${#head_text[@]}" + 1 ))
    fi

    local -i scrn_rows scrn_cols
    get_screen_size "scrn_rows" "scrn_cols"

    # Adjust values if terminal too small
    (( chars_width = scrn_cols < chars_width ? scrn_cols : chars_width ))
    if (( (line_count + head_lines) > (scrn_rows-2) )); then
        (( line_count = scrn_rows - 2 - head_lines ))
    fi

    # Centering image if indicated by position value of 0:
    if (( row==0 )); then
        (( row = (scrn_rows - (line_count+head_lines)) / 2 ))
    fi
    if (( col==0 )); then
        (( col = (scrn_cols - chars_width) / 2 ))
    fi

    # Ensure menu doesn't extend past screen bottom
    if (( row + line_count > scrn_rows )); then
        echo
        echo $'\e[31;1m'"Menu won't fit on screen."$'\e[m' >&2
        read -n1 -p "Press any key to exit program." >&2
        exit 1
    fi

    local -i top_row
    local -a key_args proc_args
    local keyp
    local -i key_proc_exit=0

    local -a show_lines_args=(
        "$lui_list_name"
        0                 # top_row, calculated and set with each iteration
        0                 # index of selected item, set with each iteration
        # "$row"
        $(( row + head_lines ))
        "$col"
        "$line_count"
        "$chars_width"
        "$line_displayer"
    )

    # disable echo while running
    local OSTTY=$( stty -g )
    stty -echo

    top_row=0

    if [ "$head_lines" -gt 0 ]; then
        plot_head=1
    fi

    while : ; do
        lui_list_calc_top_row "top_row" "$llg_selected" "$line_count"

        show_lines_args[1]="$top_row"
        show_lines_args[2]="$llg_selected"

        if [ "$plot_head" -ne 0 ]; then
            indent_print "head_text" "$row" "$col"
            plot_head=0
        fi

        lui_list_show_lines "${show_lines_args[@]}"

        if get_keypress "keyp"; then

            # Show 'help' for F1 or '?' key:
            if [ "$keyp" == $'\eOP' ] || [ "$keyp" == '?' ]; then
                lui_list_display_keys_help "$term_keys_list_name"
                reset_screen
                plot_head=1
                continue
            fi

            key_args=( "$keyp" "$llg_selected" "$top_row" "$line_count" "$row_count" )
            if lui_list_key_move_selection "llg_selected" "${key_args[@]}"; then
                continue
            fi

            proc_args=( "$keyp" "$term_keys_list_name" "$lui_list_name" "$llg_selected" )

            # restore stty for subordinate process
            stty $OSTTY

            lui_list_process_key "${proc_args[@]}" "${extra_args[@]}"
            key_proc_exit="$?"

            # return to no-echo for displaying the list
            stty -echo

            if [ "$key_proc_exit" -eq 0 ]; then
                plot_head=1
            elif (( key_proc_exit == 1 || key_proc_exit == 2 )); then
                break
            elif (( key_proc_exit > 2 )); then
                echo "Gotcha, you have to figure out a custom response for exit code $key_proc_exit." >&2
                read -n1 -p "Press any key to continue without custom response." >&2
            fi
        else
            echo "get_keypress unexpectedly returned without getting a key!" >&2
            stty $OSTTY
            exit 1
        fi
    done

    stty $OSTTY

    [ "$key_proc_exit" -gt 1 ]
}

# @def specific list interaction types
#
# There are several simple interactions types that call lui_list_generic().
# These functions perform their basic duties, but also serve as examples
# of proper usage of lui_list_generic() for custom tasks.

# Menu interaction implemented with lui_list_generic
#
# Args
#    (name):     name of integer variable in which the selection will be saved
#    (name):     name of lui_list containing the menu options
#    (integer):  maximum number of rows to display
#    (integer):  maximum number of characters per line
#    (name):     optional name of array of paragraphs for a header
lui_list_menu()
{
    local llm_selected_name="$1"
    local llm_list_name="$2"
    local -i rows="$3"
    local -i cols_requested="$4"
    local llm_header_name="$5"

    local -i cols
    # cols="$cols_requested"
    lui_list_calc_suitable_width "cols" "$llm_list_name" "$cols_requested"

    llm_line_display()
    {
        if [ "$1" -ne 0 ]; then echo -n $'\e[38;2;64;64;64;m'; fi
        hilite_pad "$3" "$2"
        echo $'\e[m'
    }

    local -a args=(
        "$llm_selected_name"
        "$llm_list_name"
        0                   # row location
        0                   # column location
        "$rows"
        "$cols"
        "llm_line_display"
        ""                  # keystroke list
        "$llm_header_name"
    )

    lui_list_generic "${args[@]}"
}

lui_list_build_menu_list()
{
    local options_name="$1"
    local strings_name="$2"
    local -i pad="$3"

    local -n llbml_options="$options_name"
    local -n llbml_strings="$strings_name"

    local string entry

    llbml_options=(1 0)
    for string in "${llbml_strings[@]}"; do
        entry=$( hilite_pad "$string" "$pad" )
        llbml_options+=( "$entry" )
    done

    lui_list_init "$options_name"
}

# Radio-button interaction implemented with lui_list_generic
#
# Args
#    (name):     name of lui_list containing the menu options
#    (integer):  maximum number of rows to display
#    (integer):  maximum number of characters per line
#    (name):     optional name of array of paragraphs for a header
lui_list_radio()
{
    if ! lui_list_validate "$1"; then
        echo "Invalid lui_list submited to lui_list_radio." >&2
        exit 1
    fi

    local llr_list_name="$1"
    local -i rows="$2"
    local -i cols_requested="$3"

    local -i cols
    lui_list_calc_suitable_width "cols" "$llr_list_name" "$cols_requested"

    local -a keylist=(
        "${LUI_DEFAULT_TERM_KEYS[@]}"
        $' :lui_list_action_radio_select:Toggle current selection'
    )

    # Ignored for calling function
    local -i selected=0

    local -a list_args=(
        "selected"
        "$llr_list_name"
        0         0            # row, column (0s to center dialog)
        "$rows" "$cols"        # height, width in characters
        "lui_list_display_selectable_line"
        "keylist"
    )

    if [ "$4" ]; then
        list_args+=( "$4" )
    fi

    lui_list_generic "${list_args[@]}"
}

# Checkbox interaction implemented with lui_list_generic
#
# Args
#    (name):     name of lui_list containing the menu options
#    (integer):  maximum number of rows to display
#    (integer):  maximum number of characters per line
#    (name):     optional name of array of paragraphs for a header
lui_list_checkbox()
{
    if ! lui_list_validate "$1"; then
        echo "Invalid lui_list submited to lui_list_checkbox" >&2
        lui_list_describe "$1" >&2
        exit 1
    fi

    local llc_list_name="$1"
    local -i rows="$2"
    local -i cols_requested="$3"
    local -i selected=0

    local -i cols
    lui_list_calc_suitable_width "cols" "$llc_list_name" "$cols_requested"

    local -a keylist=(
        "${LUI_DEFAULT_TERM_KEYS[@]}"
        $' :lui_list_action_checkbox_select:Toggle current selection'
    )

    local -a list_args=(
        "selected"
        "$llc_list_name"
        0         0          # row, column (0s for centered dialog)
        "$rows" "$cols"   # height, width in characters
        "lui_list_display_selectable_line"
        "keylist"
    )

    if [ "$4" ]; then
        list_args+=( "$4" )
    fi

    lui_list_generic "${list_args[@]}"
}

# Manage the running of elements of a list of commands.
#
# I use this function for creating scripts that test several
# aspects of a module.  The test script, *colors_test* is the
# first example of this function's use.
#
# Args
#    (name):   two-column lui_list of titles and commands to run
#    (name):   optional paragraph list to present as the list header
lui_list_runner()
{
    local name_of_test_list="$1"
    local name_of_header_paragraphs="$2"
    local -n llt_list="$1"

    run_test()
    {
        local -a row
        if lui_list_copy_row "row" "$2" "$3"; then
            reset_screen
            "${row[1]}"
            echo
            read -n1 -p "Press key to return to the test menu."
            reset_screen
            return 0
        else
            echo
            echo "Failed to find row $3 from list $2" >&2
            read -n1 -p "Press key to return to the test menu."
            reset_screen
        fi

        return 1
    }

    local -a keylist=(
        $'\e|q:LUI_ABORT'
        $'\n:run_test'
    )

    local -i selection=0
    local list_args=(
        "selection"
        "$name_of_test_list"
        0 0
        "${#llt_list[@]}"
        70
        ""
        "keylist"
        "$name_of_header_paragraphs"
    )

    reset_screen
    lui_list_generic "${list_args[@]}"
}
