# -*- mode: sh; sh-shell: bash -*-
# shellcheck disable=SC2148    # #! not appropriate for sourced script, using mode instead

# needs small_stuff, keypress

edit_text_dialog()
{
    local value_name="$1"
    local -n etd_value="$1"
    local -i limit="$2"
    local prompt="${3:-Edit the value}"

    local -i margin=2
    local -i prompt_len="${#prompt}"

    local -i row=0 col=0 rows=5 cols=$(( limit + margin ))
    get_block_centering_values row col rows cols
    draw_box "$row" "$col" "$rows" "$cols"

    local -i center_col=$(( cols/2 + col ))
    local -i prompt_col=$(( center_col - (prompt_len/2) ))

    local -i trow=$(( row + 1 ))
    local -i tcol=$(( col + 1 ))
    set_cursor_position "$trow" "$prompt_col"
    echo "${prompt}"
    set_cursor_position $(( ++trow )) "$tcol"

    edit_text "$value_name" "$limit"
    local -i retval="$?"

    block_erase "$row" "$col" "$rows" "$cols"
}


# Creates a grey-background block in which a line of text can be edited.
#
# Args
#    (name):    in/out reference to string that is in the grey block
#    (integer): length, in characters, of the grey box
edit_text()
{
   local -n et_strvalue="$1"
   local -i length="$2"

   local COLON=$'\e[48;5;238m'
   local COLOFF=$'\e[m'

   local empty=$( dupchar "$length" ' ' )

   # status variables
   local keyp
   local -i keyp_len strlen
   local str="$et_strvalue"
   local -i keyval
   local -i retval=2
   local -i cur_col str_pos
   local str_before str_after

   # frequently-used internal code as embedded function
   plot_str()
   {
       local -i prows bcols
       get_cursor_position "prows" "pcols"
       set_cursor_position "$row" "$col"
       echo -n "$str"
       dupchar $(( length - ${#str} )) ' '
       set_cursor_position "$prows" "$pcols"
   }

   # Will frequently return to starting position
   local -i row col
   get_cursor_position "row" "col"

   # Prepare and display entry area
   echo -n "${COLON}"
   echo -n "$empty"
   set_cursor_position "$row" "$col"
   echo -n "$str"
   show_cursor

   # Disable echo to prevent display of extraneous characters
   local oldstty
   oldstty=$( stty -g )
   stty -echo

   while :; do
       get_cursor_position "" "cur_col"
       (( str_pos = cur_col - col ))
       str_before="${str:0:$str_pos}"
       str_after="${str:$(( str_pos ))}"
       strlen="${#str}"

       if get_keypress "keyp"; then
           keyp_len="${#keyp}"
           if [ "$keyp" == $'\e' ]; then
               retval=1
               break
           elif [ "$keyp" == $'\n' ]; then
               retval=0
               et_strvalue="$str"
               break
           # Typeable characters are one-character long
           elif [ "$keyp_len" -eq 1 ]; then
               keyval=$( val_from_char "$keyp" )
               if [ "$keyval" == 127 ]; then
                   if [ "$strlen" -gt 0 ]; then
                       echo -n $'\e[1D'
                       str="${str_before:0:-1}${str_after}"
                       plot_str
                   fi
               elif [ "$keyval" -ge 32 ]; then
                   if [ "$strlen" -lt "$length" ]; then
                       echo -n $'\e1C'
                       str="${str_before}${keyp}${str_after}"
                       plot_str
                   fi
               fi
           # Control characters less common, test last
           elif [ "$keyp" == $'\e[H' ]; then   # Home key
               echo -n $'\e['"${row};${col}H"
           elif [ "$keyp" == $'\e[F' ]; then  # End key
               echo -n $'\e['"${row};$(( col + strlen ))H"
           elif [ "$keyp" == $'\e[D' ]; then   # Left arrow
               if [ "$str_pos" -gt 0 ]; then
                   echo -n $'\e[1D'
               fi
           elif [ "$keyp" == $'\e[C' ]; then   # Right arrow
                if [ "$str_pos" -lt "$strlen" ]; then
                    echo -n $'\e[1C'
                fi
           elif [ "$keyp" == $'\e[3~' ]; then   # DEL key
               # remote_print $(( row+3 )) 1 "You pressed the DEL key" 1
               if [ "${#str_after}" -gt 0 ]; then
                   str="${str_before}${str_after:1}"
                   plot_str
               fi
           fi
           # ignore mult-char keystrokes for new
       fi
   done

   # Retore console settings (assume cursor is hidden elsewhere):
   stty "${oldstty}"
   hide_cursor
   echo "$COLOFF"

   return "$retval"
}
