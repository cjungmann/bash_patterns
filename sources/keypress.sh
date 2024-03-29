# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

declare Control_Keys=" \	\
"

# Simple implementation of a Yes/No prompt.
# Waits for either Y or N (either case), returning 0
# for 'Y' and 1 for 'N'.
# shellcheck disable=SC2181   # quiet advice about `if cmd;` instead of `if [ $? -eq o ]`
get_yes_no()
{
    local keyp
    while true; do
        read -n1 -p"[Y]es or [N]o: " keyp
        if [ $? -eq 0 ]; then
            if [ "${keyp^^}" == "Y" ]; then
                echo
                return 0
            elif [ "${keyp^^}" == "N" ]; then
                echo
                return 1
            else
                echo -n "[2K[1G"  # erase line; move to leftmost (1) column
            fi
        fi
    done
}

# Waits for and returns single keypress, even if it is represented
# by multiple characters.
#
# This used to be the definitive get_keypress function, until I solved
# the ENTER key problem by using a *nameref* variable in which to return
# the detected keypress.  The *nameref* version is so much superior, I
# demoted this function to have the qualifier name (_echo).
get_keypress_echo()
{
    # IFS characters will be invisible to 'read', so:
    local IFS=''

    # Array to collect chars in case of multi-char keypress
    local -a chars=( )

    # Wait for a keypress (-n 1), save to array
    local keychar
    read -srn 1 keychar
    chars=( "$keychar" )

    # Collect additional characters if available, especially for escape characters
    while read -t 0; do
        read -rn 1 keychar
        chars=( "${chars[@]}" "$keychar" )
    done

    # empty IFS so array is joined without delimiters
    echo "${chars[*]}"
}

# This keypress function stores the array of characters
# to a named variable in order to preserve IFS characters.
#
# Args
#    (name):    name of variable in which the keypress string is returned
get_keypress()
{
    local -n charlist="$1"
    charlist=""

    # work variables for identifying control-presses
    local substr
    local -i val

    local -a chararr=()

    # IFS characters are invisible to read, so:
    local IFS=''

    read -srN1
    if [[ "$Control_Keys" =~ "$REPLY" ]]; then
        # Could have used small_stuff::val_from_char and ::char_from_val
        # but preferred to keep this module independent.
        substr="${Control_Keys%${REPLY}*}"
        local -i val=$(( "${#substr}" + 1 ))
        chararr+=( '^' $( printf $(printf "\\%03o" $(( val + 64 )) ) ) )
    elif [ "$REPLY" != $'\e' ]; then
        chararr+=( "$REPLY" )
    else
        chararr+=( $'\e' )

        if read -t 0; then
            read -srN1
            chararr+=( "$REPLY" )
            while read -t 0; do
                read -srN1
                if [[ "$REPLY" =~ [[:alpha:]] ]]; then
                    chararr+=( "$REPLY" )
                    break
                elif [ "$REPLY" == '~' ] && [[ "${chararr:-1:1}" =~ [[:digit:]] ]]; then
                    chararr+=( "$REPLY" )
                    break
                else
                    chararr+=( "$REPLY" )
                fi
            done
        fi
    fi

    if (( "${#chararr[*]}" > 0 )); then
        local OIFS="$IFS"
        local IFS=
        charlist="${chararr[*]}"
        IFS="$OIFS"
        return 0
    fi

    return 1
}

# Discards extra characters in the keybuffer
#
# Used in list_ui to hide extraneous keypresses when the user is
# triggering a repeating key that is disturbs the display.
clear_keybuffer()
{
    local oldstty
    oldstty=$( stty -g )

    stty -icanon min 0 time 0
    while read -r; do :; done
    stty "$oldstty"
}

