# -*- mode: sh; sh-shell: bash -*-

# Build a key action list from an array of letters.
#
# Created to support auto_menu() for a quick character-enabled
# menu.
#
# Args
#    (name-out): name of array in which the keylist will be written
#    (name-in):  name of array of letters that will trigger the callback
#    (string):   name of callback function to be triggered with matching
#              letters
auto_menu_build_keylist()
{
    local -n llbmk_keylist="$1"
    local -n llbmk_letters="$2"
    local callback="$3"

    local IFS='|'

    llbmk_keylist=(
        $'\e:LUI_ABORT:Quit menu'
        $'\n:LUI_SELECT:Select'
        "${llbmk_letters[*]}:${callback}:"
    )

    return 0
}

# Calculate the displayed character length of menu string
#
# When an underscore preceeds a letter in a menu string, the
# letter is color-highlighted and the underscore is removed,
# resulting in a display length less than the character length.
#
# Args
#    (name-out): name of integer variable in which the value is returned
#    (string):   string of characters to process
auto_menu_line_gauge()
{
    local -n amlg_len="$1"
    local str="$2"
    amlg_len="${#str}"
    if [[ "$str" =~ _[[:alnum:]] ]]; then
        (( --amlg_len ))
    fi
}

# Collects the underscore-prefixed letters (first only for each string).
#
# Args
#    (name-out): name of array variable to which to store the letters
#    (name-in):  name of lui_list whose first column contains menu strings
#    (integer):  flag, 1 if case-sensitive matching, 0 (default) to convert
#                to and only match lower case letters.
auto_menu_get_letter_array()
{
    local -n amla_letters="$1"
    local -n amla_entries="$2"
    local -i case_sensitive="$3"

    lui_list_validate "amla_entries"

    amla_letters=()

    local -i cols="${amla_entries[0]}"
    local -i els="${#amla_entries[@]}"

    local -i ndx
    local letter
    for (( ndx=2; ndx < els; ndx+=cols )); do
        if [[ "${amla_entries[$ndx]}" =~ \&([[:alnum:]]) ]]; then
            letter="${BASH_REMATCH[1]}"
            if [ "$case_sensitive" -eq 0 ]; then
                letter="${letter,,}"
            fi
            amla_letters+=( "$letter" )
        fi
    done
}


# Generates a centered menu from an array of strings.
#
# Intended for rather short lists of options for context
# menues.  Indicate that a letter triggers a match by preceding
# a letter with an underscore.  The pre-underscored letter will
# be color highlighted.
#
# Args
#    (name-out): name of variable in which the selection is returned
#    (name-in):  name of array of menu option strings
#    (integer):  flag to allow capital triggers. By default, letters
#                are converted to lower-case so uses don't need to
#                capitalize their responses.  If you need to
#                distinguish between 'f' and 'F', set this parameter
#                to 1 (or any non-zero integer).
auto_menu()
{
    local selected_name="$1"
    local list_name="$2"
    local -i allow_capitals="$3"

    local -i rows cols
    lui_list_row_count "rows" "$list_name"
    cols=$( lui_list_max_len "$list_name" "auto_menu_line_gauge" )

    local -i row col
    get_block_centering_values "row" "col" "rows" "cols"

    local -i brow=$((row-1)) bcol=$((col-1)) brows=$((rows+2)) bcols=$((cols+2))

    # inscribe a box around the menu:
    draw_box "$brow" "$bcol" "$brows" "$bcols"

    # Build a keylist from letters extracted from option strings:
    local -a letters=()
    auto_menu_get_letter_array "letters" "$list_name" "$allow_captials"

    # Make searchable list of letters
    local OIFS="$IFS"
    local IFS=''
    local letterarray="${letters[*]}"
    IFS="$OIFS"

    llam_key_action()
    {
        local keyp="$1"
        local -n llam_selected="$selected_name"
        local -i ndx
        if ndx=$( strstrndx "$letterarray" "$keyp" ); then
            llam_selected="$ndx"
            return 2
        fi

        return 0
    }

    local -a mkeylist=()
    auto_menu_build_keylist "mkeylist" "letters" "llam_key_action"

    # Minimal line display for formated strings
    llam_line_display()
    {
        local col_normal=$'\e[37;1m'
        local col_emph=$'\e[38;5;208m'
        if [ "$1" -ne 0 ]; then
            col_normal="${col_normal}"$'\e[48;5;238m'
        fi
        hilite_pad "$3" "$2" "$col_emph" "$col_normal"
        echo $'\e[m'
    }

    local -a args=(
        "$selected_name"
        "$list_name"
        "$row" "$col" "$rows" "$cols"
        "llam_line_display"
        "mkeylist"
    )

    lui_list_generic "${args[@]}"
    local -i ecode="$?"

    block_erase "$brow" "$bcol" "$brows" "$bcols"

    return "$ecode"
}


# Simple array version of auto_menu
#
# Args
#    (name-out): name of integer variable in which the selected element will be written
#    (name-in):  name of simple array of strings from which the menu will be built
#    (integer):  capitalization flag (see auto_menu)
auto_menu_array()
{
    local -n ama_array="$2"
    local -a ama_lui_list
    lui_list_convert "ama_lui_list" "ama_array" 1 1

    auto_menu "$1" "ama_lui_list" "$3"
}
