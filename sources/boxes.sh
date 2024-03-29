# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# requires "small_stuff" module

# rounded corders
declare c_tl=$'\u256D'
declare c_tr=$'\u256E'
declare c_bl=$'\u2570'
declare c_br=$'\u256F'

declare c_side=$'\u2502'
declare c_flat=$'\u2500'

# @def Using boxes
#
# The motive of drawing a box is to provide separation from
# underlying content when putting a context dialog on the
# screen.  It makes it easier to read, and it looks a lot
# nicer.
#
# The primary function, draw_box() takes four arguments,
# the top-left corner's row and column values, followed by
# the number of rows and columns to which the box is printed.
#
# One preliminary step is to determine the values of the four
# arguments.  There are tools for doing that in the block_text
# module (block_text_get_size()) and module small_stuff
# (get_block_centering_values()).
#
# Here is an example (you can also find the example in "boxes_test").
#
# declare str="This is a message."
# declare -i row col rows=5 cols=$(( "${#str}" + 2 ))
# get_block_centering_values "row" "col" "rows" "cols"
# draw_box "$row" "$col" "$rows" "$cols"
# set_cursor_position $(( row+2 )) $(( col+1 ))
# echo -n "$str"
# # Move cursor out of box to avoid disturbing the box borders:
# echo

# Function to help select an safe and appropriate content width.
#
# This function is meant to help format messages.  It may not
# be appropriate for picking a screen width for table or other
# views that may want to exploit as much screen width as possible.
#
# Args
#    (name):     name of variable in which the result is written
#    (integer):  optional preferred width
get_pleasing_content_width()
{
    local -n gpw_columns="$1"
    local -i preferred="${2:-60}"

    local -i srows scols
    get_screen_size "srows" "scols"

    # Leave at least two characters of  margins
    (( scols -= 4 ))

    if (( preferred > 0 && preferred < scols )); then
        (( gpw_columns = preferred ))
    elif (( scols > 100 )); then
         (( gpw_columns = 100 ))
    else
        (( gpw_columns = scols ))
    fi
}

# Draws an empty box at the specified position and extent.
#
# Args
#    (integer):    row position of upper-left corner of box
#    (integer):    column position of upper-left corner of box
#    (integer):    number of rows over which the box extends
#    (integer):    number of columns over which the box extends
draw_box()
{
    local -i row="$1"
    local -i col="$2"
    local -i rows="$3"
    local -i cols="$4"

    set_cursor_position "$row" "$col"
    draw_horizontal "$cols" 1

    for (( i=0; i<rows-2; ++i )); do
        set_cursor_column "$col"
        draw_sides "$cols"
    done

    set_cursor_column "$col"
    draw_horizontal "$cols" 0
}

# Internal function draws the corners and the horizontal line beween.
#
# Printing begins at the current cursor position.  Make sure the
# cursor is in the appropriate position before calling the function
#
# Args
#    (integer):   number of characters wide, including corners
#    (integer):   top-or-bottom flag to determine orientation of
#                 corner characters.  0 for top, non-zero for bottom.
draw_horizontal()
{
    local -i count="$1"
    local -i top="$2"

    local cleft cright

    if [ "$top" -eq 0 ]; then
        cleft="$c_bl"
        cright="$c_br"
    else
        cleft="$c_tl"
        cright="$c_tr"
    fi

    local flat
    printf -v flat "%0$((count-2))d" 0
    flat="${flat//0/${c_flat}}"
    echo "${cleft}${flat}${cright}"
}

# Internal function draws one line of border vertical characters with
# empty spaces between
#
# Printing begins at the current cursor position.  Make sure the
# cursor is in the appropriate position before calling the function
#
# Args
#    (integer):    characters wide
draw_sides()
{
    local -i width="$1"
    local empty
    printf -v empty "%0$((width-2))d" 0
    empty="${empty//0/ }"
    echo "${c_side}${empty}${c_side}"
}

