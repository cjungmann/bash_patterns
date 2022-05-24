# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# @def Number manipulation functions, especially for currency.
#
# Bash can only do math on integer values, so handling currency
# values, which can include cents as fractional dollars, as numbers
# requires special treatment.  We're multiplying the currency values
# by 100, so dollar values are represented by the number of cents.
#
# In memory of 1980's Turbo Pascal, I'll refer to these values as
# 'Binary-Coded Decimals' or BCDs.
#
# Functions in_cent_ivize() and de_cent_ivize() converts between
# currency strings and BCDs.
#
# Function commaize_number() will convert an integer value to a
# string that includes appropriately-positioned commas.


# Add commas and, if requested, a decimal point to an integer value.
#
# Args
#    (name):     name of variable to which the resulting string is copied
#    (integer):  value to be converted
#    (integer):  BCD flag.  If 1, show cents with a period
commaize_number()
{
    local -n return_var="$1"
    local -i val="$2"
    local -i bcd="$3"

    local -i remains
    local -a parts=()

    looper()
    {
        local -i part=$(( remains % 1000 ))
        (( remains /= 1000 ))
        if [ "$remains" -gt 0 ]; then
            looper
            (( part += 1000 ))
            parts+=( "${part:1}" )
        else
            parts+=( "$part" )
        fi
    }

    local sign=""
    if [ "$val" -lt 0 ]; then
        sign="-"
        (( remains = -val ))
    else
        (( remains = val ))
    fi

    local IFS=','
    if [ "$bcd" -ne 0 ]; then
        local -i cents=$(( (remains % 100) + 100 ))
        (( remains /= 100 ))
        looper
        return_var="${sign}${parts[*]}.${cents:1}"
    else
        looper
        return_var="${sign}${parts[*]}"
    fi
}

declare IN_CENT_IVIZE_RE=[[:digit:]].[[:digit:]]{2}

# Currency to cents using a series of substitutions to remove punctuation.
#
# Bash only handles integer math, so this function helps by converting
# currency (US currency style) to cents.
#
# Args
#    (name):     name of variable in which the answer is returned.
#    (string):   string representation of currency value
in_cent_ivize()
{
    local -n ss_val="$1"

    local val sign=""
    if [ "${2:0:1}" == "-" ]; then
        sign="-"
        val="${2:1}"
    else
        val="$2"
    fi

    val="${val/\$/}"
    val="${val/,/}"

    # handle case with whole dollars and no cents.
    if [[ "$val" =~ $IN_CENT_IVIZE_RE ]]; then
        val="${val/./}"
    else
        val="${val}00"
    fi

    ss_val="$sign"$(( 10#$val ))
}

# Convert number of cents to a currency number, i.e. 10000 to "100.00"
de_cent_ivize()
{
    local -n dci_val="$1"
    local -i dci_cents="$2"

    local sign=""
    if [ "$dci_cents" -lt 0 ]; then
        (( dci_cents = -dci_cents ))
        sign="-"
    fi

    local -i dollars
    local -i cents
    (( dollars = dci_cents/100 ))
    (( cents = 100 + (dci_cents % 100) ))

    dci_val="${sign}${dollars}.${cents:1}"
}


