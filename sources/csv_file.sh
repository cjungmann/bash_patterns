# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# requires sources/list_ui

# Returns CSV-parsing regular expression
#
# The reason for this function is to make it easier to assign
# the array-origin regular expression without disturbing the
# global IFS value
get_csv_regex()
{
    local IFS=$'\n'

    # parentheses must be quoted or escaped to avoid being interpreted
    # as a Bash token.

    # This regular expression matches double-quote enclosed fields that
    # contain a comma in order to temporarily replace the enclosed comma
    # with another character until the other commas are used to split the
    # string into array elements.
    # 
    # The non-optional double-quote in this regular expression is
    # appropriate because the expression doesn't try to match un-enclosed
    # fields: they won't contain a comma 
    local -a re_parts=(
        '(.*)'      # optional preceding characters
        '(,?)'      # optional comma (not before the first field)
        \"          # introducing the quote-enclosed field
        \(          # introducing a match group   NOTE: this and other parentheses
                    # must be escaped or quoted to prevent unwanted Bash interpretation.
        [^,\"]+     # match characters that are neither a close-quote or a comma
        \)          # concluding first match group
        ,           # match a comma within the enclosing quotes
        \(          # introducing second match group
        [^\"]+      # match remainder of characters in quotes
        \)          # conclusion of second match group
        \"          # conclusion of quote-enclosed field
        '(,?)'      # optional comma (not after the last field)
        '(.*)'      # optionaal succeeding characters
    )
    IFS=
    echo "${re_parts[*]}"
}

declare CSV_RE=$( get_csv_regex )

# Populate an array with the values of a CSV line.
#
# Not a perfect implementation, it doesn't attempt to recognize
# escaped characters, especially quotes or apostrophes, and it will
# choke on text fields that include newlines.  It should suffice,
# however, for most CSV documents, especially those originating from
# financial statements.
#
# Args
#    (name):   name of array into which the values are stored
#    (string): a single CSV line
array_from_csv_line()
{
    local -n pcl_cells="$1"
    local line="$2"
    local standin=$'\x01'  # ascii SOH (start of heading)

    # alias for shorter access
    local -n BR="BASH_REMATCH"

    # Repeat until no more quote-enclosed commas:
    while [[ "$line" =~ $CSV_RE ]]; do
        line="${BR[1]}${BR[2]}\"${BR[3]}${standin}${BR[4]}\"${BR[5]}${BR[6]}"
    done

    # Replace remaining commas with a second standin, then
    # split the string into an array using the same standin
    local IFS=$'\x02'

    # Replace commas with IFS non-printable character
    line="${line//,/${IFS}}"
    # Restore stoodin commas
    line="${line//${standin}/,}"
    # Make an array from the results so far
    pcl_cells=( $line )

    # Remove cell-enclosing quotes
    local val
    local -i el_count="${#pcl_cells[@]}"
    local -i i
    for (( i=0; i<el_count; ++i )); do
        val="${pcl_cells[$i]}"
        pcl_cells["$i"]="${val//\"/}"
    done
}


# Create lui_list of values and an array of raw lines from file contents
#
# Args
#    (name):   name of lui_list of data into which data will be written
#    (name):   name of simple array of text lines to be populated from file contents
#    (string): path to file to read
csv_read_file()
{
    local name_lui_list="$1"
    local -n crf_lui_list="$1"

    local name_csv_list="$2"
    local -n crf_csv_lines="$2"
    local filepath="$3"

    if [ -f "$filepath" ]; then
        crf_lui_list=()
        crf_csv_lines=()

        local -a currow
        local curline
        local -i elcount=0
        while IFS= read -e curline; do
            crf_csv_lines+=( "$curline" )
            array_from_csv_line "currow" "$curline"

            # Initialize the lui_list for the first line
            if [ "$elcount" -eq 0 ]; then
                array_from_csv_line "currow" "$curline"
                elcount="${#currow[@]}"
                crf_lui_list=( "$elcount" 0 )
            fi

            lui_list_append_row "$name_lui_list" "currow"
        done < "$filepath"

        return 0
    else
        echo "Error opening file $filepath" >&2
        return 1
    fi
}

write_csv_to_file()
{
    local target="$1"
    local source_name="$2"

    local -n source="$source_name"
    local -i cols="${source[0]}"

    write_line()
    {
        local -i ndx="$1"
        shift
        local -i first=0
        local arg
        for arg in "$@"; do
            if [ $(( first++ )) -gt 0 ]; then
                echo -n ','          >> "$target"
            fi

            if [[ "$arg" =~ ',' ]]; then
                echo -n "\"${arg}\"" >> "$target"
            else
                echo -n "$arg"       >> "$target"
            fi
        done
        echo >> "$target"
    }

    echo -n > "$target"

    lui_list_iterate "$source_name" "write_line"
}
