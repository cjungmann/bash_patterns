# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# @def Two functions in support of timing processes
#
# Take timings before and after a process, the difference is the
# length of time taken by the process.
#
# The resolution is in ten-thousandths of a second.
#
# get_time_in_tenthous():
#   Returns the number of 1/10000ths of seconds since midnight.
#
# show_tenthous_as_floating_seconds()
#   Returns a value of 1/10000ths of seconds to a floating
#   seconds string.

# Returns number of 1/10000ths of a second since midnight
#
# Args: none
get_time_in_tenthous()
{
    local IFS='.'
    local -a parts=( $( date +"%k.%-M.%-S.%N" ) )
    local -i since_midnight=$(( ( (parts[0] * 60) + parts[1] ) * 60 + parts[2] ))
    local -i frac=$(( "10#${parts[3]:0:4}" ))
    if [ "${parts[3]:4:1}" -gt 4 ]; then
        (( ++frac ))
    fi

    echo $(( (since_midnight * 10000) + frac ))
}

# Return floating-value seconds of a value of 10000ths of seconds
#
# Args
#    (integer):  number of 1/1000 seconds
show_tenthous_as_floating_seconds()
{
    local -i val="$1"
    local -i raw_seconds=$(( val / 10000 ))

    local -i hours=$(( raw_seconds / 3600 ))
    local -i minutes=$(( (raw_seconds / 60) % 60  ))
    local -i seconds=$(( raw_seconds % 60  ))

    if [ "$hours" -ne 0 ]; then
        (( minutes += 100 ))
        (( seconds += 100 ))
        echo -n "${hours}:${minutes:1}:${seconds:1}"
    elif [ "$minutes" -ne 0 ]; then
        (( seconds += 100 ))
        echo -n "${minutes}:${seconds:1}"
    else
        echo -n "$seconds"
    fi

    local frac=$(( val % 10000 ))
    if [ "$frac" -ne 0 ]; then
        (( frac += 10000 ))
        frac="${frac:1}"

        # remove trailing 0s with extended pattern matching:
        local optset=$( get_shopt_setting "extglob" )
        shopt -s extglob
        echo ".${frac%%+(0)}"
        shopt -"${optset}" extglob
    else
        echo
    fi
}
