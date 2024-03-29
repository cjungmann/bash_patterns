# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# Print a message at designated position on screen.
#
# This is intended for debugging rather than user notification.
# It saves the cursor position, moves to specified location to
# print the message, then returns to the original position to
# minimally disturb the user interface.
#
# To prevent confusion resulting from short messages following
# longer ones, the entire line following the message is erased.
# This may not be pretty, but this is debugging. It it's too
# disruptive, put the message elsewhere.
#
# Args
#    (integer): row at which to print the message
#    (integer): column at which to print the message
#    (string):  message to print
#    (integer): pause flag:
#                  1: after showing message, pause, then erase message
#                  0: print message and return
remote_print()
{
    local -i row="$1"
    local -i col="$2"
    local message="$3"
    local -i wait_and_erase="${4:-0}"
    local -i saved_row saved_col
    get_cursor_position "saved_row" "saved_col"
    set_cursor_position "$row" "$col"
    echo -n $'\e[K'
    echo "$message"
    if [ "$wait_and_erase" -ne 0 ]; then
        local prompt="Press a key"
        read -n1 -p "$prompt"
        set_cursor_position "$row" "$col"
        echo -n $'\e[K'
        dupchar "${#message}" ' '
        set_cursor_position $(( row+1 )) "$col"
        echo -n $'\e[K'
        dupchar "${#prompt}" ' '
    fi

    set_cursor_position "$saved_row" "$saved_col"
}



# @def Variable Validation Functions
#
# In an effort to shorten debugging time by identifying problems
# with function arguments, these functions aim to verify the
# existence and types of variables, especially variable names
# to be used as nameref variables.
#
# I justify the use of Bash-only tests because this is
# 'bash_patterns', and much of this set of scripts are
# dependent on Bash arrays and other Bash-specific stuff.


# Tests if named variable has been declared
#
# Args
#    (name):   name of variable to test
named_var_exists() { declare -p "$1" &>/dev/null; }

# Tests if a named variable is of a given type
#
# Args
#    (name):      name of variable to test
#    (character): letter of declare type: 'a' for array, 'i' for int
named_var_is_type()
{
    if named_var_exists "$1"; then
        local type="-$2"
        local result
        if result=$( declare -p "$1" ); then
            if [ "${result:8:2}" == "$type" ]; then
                return 0
            fi
        fi
    fi

    return 1
}


# Recursively resolves nameref variables back to non-nameref variable
# 
# Args
#    (name):   name of variable to discern
original_var_name()
{
    local str=$( declare -p "$1" 2>/dev/null )
    if [ "${str:8:2}" == "-n" ]; then
        if [[ "$str" =~ =\"([^\"]+)\" ]]; then
            original_var_name "${BASH_REMATCH[1]}"
        else
            echo "Failed to match the '$str'" >&2
            to_continue
        fi
    else
        echo "$1"
    fi
}

# Alias for named_var_is_type $1 'i'
named_var_is_int()
{
    local n=$( original_var_name "$1" );
    named_var_is_type "$n" "i";
}

# Alias for named_var_is_type $1 'a'
named_var_is_array()
{
    local n=$( original_var_name "$1" );
    named_var_is_type "$n" "a";
}

# Indicates if a given name is a function
named_var_is_function() { [ $( type -t "$1" ) == "function" ]; }

# Test a value rather than a variable
value_is_int() { [[ "$1" =~ ^[+-]?[[:digit:]]+ ]]; }

