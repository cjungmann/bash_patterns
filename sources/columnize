# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead


populate_string_lengths_array()
{
    local -n sla_out="$1"
    local -n sla_array="$2"

    sla_out=()
    local -i slen
    local el
    for el in "${sla_array[@]}"; do
        string_len_sans_csi "slen" "$el"
        sla_out+=( "$slen" )
    done
}

get_average_string_length()
{
    local -n gasl_average_length="$1"
    local -n gasl_lengths="$2"

    local -i els="${#gasl_lengths[@]}"
    local -i cumlen=0

    local -i len
    for len in "${gasl_lengths[@]}"; do
        (( cumlen += len ))
    done

    (( gasl_average_length = cumlen / els ))
}

assign_column_widths()
{
    local -n acw_column_widths="$1"
    local -n acw_rows="$2"
    local -n acw_lengths_array="$3"
    local -i screen_width="$4"
    local -i gutter="${5:-2}"

    local -i els_count="${#acw_lengths_array[@]}"

    # Make informed column count guess to start
    local -i average_width col_count
    get_average_string_length "average_width" "$3"
    (( col_count = screen_width / average_width ))

    local -i slen
    local -i cur_row=0
    local -i col_width cum_width=0

    while (( col_count > 0 )); do
        (( acw_rows = ( els_count / col_count ) + ( els_count % col_count ? 1 : 0 ) ))
        cum_width=0
        col_width=0
        cur_row=0
        col_index=0

        acw_column_widths=()

        for slen in "${acw_lengths_array[@]}"; do
            (( col_width = ( slen > col_width ? slen : col_width ) ))
            if (( ++cur_row == acw_rows )); then
                # except for right-most column, add gutter to column width
                if (( ++col_index < col_count )); then
                    (( col_width += gutter ))
                fi
                # save accumulated lengths
                acw_column_widths+=( "$col_width" )
                (( cum_width += col_width ))

                # setup for next column
                col_width=0
                cur_row=0
            fi
        done

        # catch leftovers
        if [ "$cur_row" -gt 0 ]; then
            acw_column_widths+=( "$col_width" )
            (( cum_width += col_width ))
        fi

        # Break if it fits
        if (( cum_width < screen_width )); then
            return 0
        fi

        (( --col_count ))
    done

    return 1
}



columnize()
{
    local -n c_array="$1"
    local -i gutter="${2:-2}"

    # Collecting info for informed row count guess
    local -i screen_width
    get_screen_size "" "screen_width"

    local -a string_lengths
    populate_string_lengths_array "string_lengths" "$1"

    local -a column_widths
    local -i rows

    if assign_column_widths "column_widths" "rows" "string_lengths" "$screen_width" "$gutter"; then
        local -i els_count="${#c_array[@]}"

        local -i row col_ndx col_number col_width str_width
        for (( row=0; row < rows; ++row )); do
            for (( col_ndx=row, col_number=0; col_ndx < els_count; col_ndx+=rows, ++col_number )); do
                col_width="${column_widths[$col_number]}"
                # Avoid resurvey of string lengths by reusing previously-saved values
                str_width="${string_lengths[$col_ndx]}"
                echo -n "${c_array[$col_ndx]}"
                dupchar $(( col_width - str_width )) ' '
            done
            echo
        done
    fi
}
