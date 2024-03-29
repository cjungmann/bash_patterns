# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# shellcheck disable=SC2034 # don't warn about nameref variables that are only read by caller

# @def Script to print dimensionally-constrained text.
#
# Calculates a centered position for the contents of an array
# of text strings, then displays the text within the constraints.
#
# Line lengths are calculated by counting characters that are not
# part of CSI-prefixed codes, so lines may include color-highlighted
# text without ruining the block display.
#
# Look at script 'block_text_test' for a usage example.

# @def Script dependencies
# This script uses functions found in 'small_stuff' and 'keypress'.

# For CSI-containing text block, returns the printing size of a
# text block in rows and columns.
#
# Args
#    (name):     name of integer in which the row count is returned.
#    (name):     name of integer in which the column count is returned.
#    (name):     name of array of text strings to print
block_text_get_size()
{
    local -n gbd_rows="$1"
    local -n gbd_cols="$2"
    local -n btgs_lines="$3"

    gbd_rows="${#btgs_lines[@]}"
    gbd_cols=0

    local -i curlen maxlen
    local line

    for line in "${btgs_lines[@]}"; do
        string_len_sans_csi "curlen" "$line"
        (( maxlen = curlen > maxlen ? curlen : maxlen ))
    done

    gbd_cols="$maxlen"
}

# Prints the text block and handles the scrolling
#
# Lines with ANSI codes near the end may 
#
# Args
#    (name-in):  name of array of text strings to be printed
#    (integer):  index of the first line to print in text strings array
#    (integer):  row position from which to start printing text
#    (integer):  column position from which to start printing text
#    (integer):  number of rows to print at once
#    (integer):  number of columns to print (padded to end, cut if too long)
block_text_print()
{
    local -n btp_lines="$1"
    local -i top="$2"
    local -i btp_origin_row="$3"
    local -i btp_origin_col="$4"
    local -i rows="$5"
    local -i cols="$6"

    set_cursor_position "$btp_origin_row" "$btp_origin_col"

    local -a tarray=( "${btp_lines[@]:$top:$rows}" )

    local line padding
    local -i count=0
    local -i curwide

    # Truncate too-long lines:
    disable_autowrap

    for line in "${tarray[@]}"; do
        string_len_sans_csi "curwide" "$line"
        if [ "$curwide" -lt "$cols" ]; then
            line="$line$( dupchar $(( cols - curwide )) ' ')"
        fi

        # newline BEFORE printing to avoid extra newline at end
        if (( count++ > 0 )); then
            echo
        fi
        set_cursor_column "$btp_origin_col"
        echo -n "$line"
    done

    enable_autowrap

    set_cursor_position 99999 1
}

# Block text interaction manager
#
# Given an array of text lines and row and column constraints, this
# function calculates a screen-centered position then manages an
# event loop to allow a scrolling interaction with the contents.
#
# If either or both of the second and third parameters are 0,
# the respective limits will be set according to the content of
# the nameref array.
#
# Args
#    (name):     name of array of text lines
#    (integer):  display block size in rows
#    (integer):  display block size in columns
block_text_display()
{
    local array_name="$1"
    local -i print_rows="$2"
    local -i print_cols="$3"

    local -i blk_rows blk_cols
    block_text_get_size "blk_rows" "blk_cols" "$array_name"

    # Center based on contents width if not specified
    if [ "$print_cols" -eq 0 ]; then
        print_cols="$blk_cols"
    fi

    if [ "$print_rows" -eq 0 ]; then
        print_rows="$blk_rows"
    fi

    local -i scr_rows scr_cols
    get_screen_size "scr_rows" "scr_cols"

    # Sanity check: shrink if too large
    if [ "$scr_rows" -lt "$print_rows" ]; then
        print_rows="$scr_rows"
    fi
    if [ "$scr_cols" -lt "$print_cols" ]; then
        print_cols="$scr_cols"
    fi

    # top value if fully-scrolled down
    local -i maxtop=$(( blk_rows - print_rows  ))

    local -i top=0
    local -a text_block_args=(
        "$array_name"                         # name of array of text lines
        0                                     # top row, starting at 0
        $(( (scr_rows - print_rows) / 2 ))    # rows origin
        $(( (scr_cols - print_cols) / 2 ))    # columns origin
        "$print_rows"
        "$print_cols"
        )

    local keyp

    reset_screen

    disable_echo
    while :; do
        block_text_print "${text_block_args[@]}"
        if get_keypress "keyp"; then
            case "$keyp" in
                $'\e' | 'q' | $'\n' ) break ;;
                $'\e[A' ) # up arrow
                    (( top = (top > 0 ? --top : top) ))
                    ;;
                $'\e[B' ) # down arrow
                    (( top = (top < maxtop) ? ++top : top ))
                    ;;
                $'\e[5~') # PgUp
                    (( top -= print_rows,  top = (top < 0) ? 0 : top ))
                    ;;
                $'\e[6~') # PgDn
                    (( top += print_rows, top = (top > maxtop) ? maxtop : top ))
                    ;;

            esac

            text_block_args[1]="$top"
        fi
    done
    enable_echo
}

# Simple function to center-print short text.
#
# Args
#    (name):   name of array of formatted text strings
block_text_centered()
{
    local -n btc_lines="$1"

    local -i rows cols
    block_text_get_size "rows" "cols" "$1"

    local -i row col
    get_block_centering_values "row" "col" "rows" "cols"

    set_cursor_position "$row" "$col"

    local line
    for line in "${btc_lines[@]}"; do
        echo "$line"
        set_cursor_column "$col"
    done
}

# Print spaces in described area to erase contents.
#
# Args
#    (integer):   block origin row
#    (integer):   block origin column
#    (integer):   number of rows to erase
#    (integer):   number of columns to erase
block_erase()
{
    local -i row="$1"
    local -i col="$2"
    local -i rows="$3"
    local -i cols="$4"

    local estr=$( dupchar "$cols" ' ' )
    set_cursor_position "$row" "$col"
    for (( i=0; i<rows; ++i )); do
        echo "$estr"
        set_cursor_column "$col"
    done
    set_cursor_column 1
}

# Create interactive display of paragraphs, formatted according
# to the current screen size.
#
# Args
#   (name-in):  name of array of unformatted paragraphs
#   (integer):  optional target content width
paragraphs_interaction()
{
    local paras_var_name="$1"
    local -i width="${2:-60}"

    local -a lines
    format_paragraphs "lines" "$paras_var_name" "$width"

    local -i rows cols
    get_screen_size "rows" "cols"

    local -i para_count="${#paras[@]}"
    local -i line_count="${#lines[@]}"
    local -i content_rows=$((  para_count + line_count ))

    (( rows = ( (rows-5) < content_rows ) ? (rows-5) : content_rows ))

     block_text_display "lines" "$rows" "$width"

     reset_screen
}
