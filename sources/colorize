# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

declare Cz_Bold="$LESS_TERMCAP_md"
declare Cz_Ital="$LESS_TERMCAP_us"
declare Cz_Undo="$LESS_TERMCAP_me"

# @def Introduction
#
# This is a very basic word colorizer.  It can only set
# two colors:
# 
# - ${Cz_Bold}bold${Cz_Undo} if a word is enclosed with
#   either double asterisks or two underscores.  __bold__
#
# - ${Cz_Ital}italic${Cz_Undo} if a word is enclosed with
#   either single asterisks or two underscores. _italic_.
#
# The color tokens are familiar from Markdown, but they are
# nowhere near as powerful.  Each word must be colorized individually,
# and they cannot be nested, that is, no bold-italc with triple
# asterisks or underscores.
#
# Escpaing spaces will not work to group colored words because I'm
# using a simple-minded builtin Bash method to separate words that
# doesn't notice the escaped spaces.
#
# The returned array will have only the words without spaces, which
# can be reconstitued by "${result[*]}" with IFS=$' '.

# Parse a line flags string to set line style flags
#
# Args
#    (name-out):   nameref of italics flag
#    (name-out):   nameref of bold flag
#    (name-out):   nameref of format flag
#    (name-out):   nameref of center flag
#    (string):     line flags string
parse_colorize_flags()
{
    local bogus
    local -n pcf_ital="${1:-bogus}"
    local -n pcf_bold="${2:-bogus}"
    local -n pcf_format="${3:-bogus}"
    local -n pcf_center="${4:-bogus}"
    local string="$5"

    ! [[ "$string" =~ (^[^_]*_[^_]*$)|(^[^*]*\*[^*]*$) ]];  pcf_ital="$?"
    ! [[ "$string" =~ (__)|(\*\*) ]]; pcf_bold="$?"
    ! [[ "$string" =~ \^ ]];          pcf_center="$?"
    ! [[ "$string" =~ ! ]];           pcf_format="$?"
}


# Break string into words, discarding inter-word spaces.
#
# Uses *read* to break string into an array
#
# Args
#    (name-out):    array in which string is broken
#    (string):      string to break up
arrayify_spaceless()
{
    read -ra "$1" <<< "$2"
}

# Break string into words, maintaining formatting (spaces)
#
# Args
#    (name-out):    array in which string is broken
#    (string):      string to break up
arrayify_keep_spaces()
{
    local -n aks_arr="$1"
    local str="$2"

    local val
    local -a word=()
    local -a spaces=()
    local char

    local -i wcount=0
    local -i scount=0

    local IFS=

    while IFS= read -rn1 char && [ "$char" != $'\0' ]; do
        wcount="${#word[*]}"
        scount="${#spaces[*]}"
        if [[ "$char" =~ [[:space:]] ]]; then
            if [ "$scount" -eq 0 ]; then
                if [ "$wcount" -gt 0 ]; then
                    aks_arr+=( "${word[*]}" )
                    word=()
                fi
            fi
            spaces+=( "$char" )
        else   # [ ![[:space:]] ]
            if [ "$wcount" -eq 0 ]; then
                if [ "$scount" -gt 0 ]; then
                    aks_arr+=( "${spaces[*]}" )
                    spaces=()
                fi
            fi
            word+=( "$char" )
        fi
    done <<< "$str"

    if [ "$wcount" -gt 0 ]; then
        aks_arr+=( "${word[*]}" )
    fi
}

# Colorize words by enclosing them with CSI colors.
#
# Args
#    (name-out):  name of string in which colorized string is returned
#    (string):    string of text to be colorized
colorize_string()
{
    local -n cs_line="$1"
    local cs_input="$2"

    cs_line=""
    local -a cs_output=()
    local output_ifs=' '

    bold_enclosed() { [[ "$1" =~ ^__(.*)__$ ]] || [[ "$1" =~ ^\*\*(.*)\*\*$ ]]; }
    ital_enclosed() { [[ "$1" =~ ^_(.*)_$ ]] || [[ "$1" =~ ^\*(.*)\*$ ]]; }

    local cz_undo="${Cz_Undo}"

    local -i line_ital=0 line_bold=0 line_format=0 line_center=0
    local fname="arrayify_spaceless"
    local reinput=^!\([^\ ]*\ \)\(.*\)$
    if [[ "$cs_input" =~ $reinput ]]; then
        cs_input="${BASH_REMATCH[2]}"

        local style_args=(
            line_ital
            line_bold
            line_format
            line_center
            "${BASH_REMATCH[1]}"
        )
        parse_colorize_flags "${style_args[@]}"

        if [ "$line_format" -ne 0 ]; then
            fname="arrayify_keep_spaces"
            output_ifs=''
        fi
        # Bold+Ital not possible, Bold take precedence
        if [ "$line_bold" -ne 0 ]; then
            cz_undo="$Cz_Bold"
        elif [ "$line_ital" -ne 0 ]; then
            cz_undo="$Cz_Ital"
        fi
    fi

    # Arrayify the string
    "$fname" "cs_output" "$cs_input"

    local word redo punct
    local -i ndx=0
    for word in "${cs_output[@]}"; do
        redo=
        if [[ "$word" =~ ^(.*)([,.!;:+&]+)$ ]]; then
            word="${BASH_REMATCH[1]}"
            punct="${BASH_REMATCH[2]}"
        else
            punct=
        fi

        if bold_enclosed "$word"; then
            redo="${Cz_Bold}${BASH_REMATCH[1]}${cz_undo}"
        elif ital_enclosed "$word"; then
            redo="${Cz_Ital}${BASH_REMATCH[1]}${cz_undo}"
        fi

        if [ -n "$redo" ]; then
            if [ -n "$punct" ]; then
                redo="${redo}${punct}"
            fi
            cs_output["$ndx"]="$redo"
        fi

        (( ++ndx ))
    done

    if [ "$cz_undo" != "$Cz_Undo" ]; then
        cs_output[0]="${cz_undo}${cs_output[0]}"
        cs_output[-1]="${cs_output[-1]}${Cz_Undo}"
    fi

    IFS="$output_ifs"
    cs_line="${cs_output[*]}"
}

# Colorize every line of an array
#
# Args
#    (name-io):   name of source array that will be colorized
colorize_array()
{
    local -n ca_strings_array="$1"

    local IFS OIFS="$IFS"

    local colorline
    local string
    local -i ndx=0

    for string in "${ca_strings_array[@]}"; do
        colorize_string "colorline" "$string"
        ca_strings_array[$(( ndx++ ))]="$colorline"
    done
}
