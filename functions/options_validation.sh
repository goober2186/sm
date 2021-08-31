#!/bin/bash

# Function to get selected options
options() {
  # This sets the OPTIONS variable that was passed into the function
  OPTIONS=$1
  # This sets the output filename to OUTPUT
  OUTPUT=$2
  # This gets the length of the string OPTIONS
  chrlen=${#OPTIONS}

  #This sets valid to 0 and will increase to 1 if any of the options are correct
  validi=0
  valida=0
  validp=0
  valids=0

  # This sets the starting column and serial will always be first
  echo -n "Serial," >> $OUTPUT

  #This loops through the OPTIONS String to find the correct inputs and if there are none sets default column headers
    for (( l=0; l<=$chrlen; l++ ))
      do
        char=${OPTIONS:$l:1}
        if [ "$char" == "i" ] && [ $validi -eq 0 ]; then
          echo -n "ID," >> $OUTPUT
          validi=1
        elif [ "$char" == "a" ] && [ $valida -eq 0 ]; then
          echo -n "IP," >> $OUTPUT
          valida=1
        elif [ "$char" == "p" ] && [ $validp -eq 0 ]; then
          echo -n "Switch1,Port1,Switch2,Port2," >> $OUTPUT
          validp=1
        elif [ "$char" == "s" ] && [ $valids -eq 0 ]; then
          echo -n "State," >> $OUTPUT
          valids=1
        else
          :
        fi
      done
      if [ $validi -eq 0 ] && [ $valida -eq 0 ] && [ $validp -eq 0 ] && [ $valids -eq 0 ]; then
        echo -n "ID,IP,Switch1,Port1,Switch2,Port2,State," >> $output
      fi
      echo "" >> $OUTPUT
}

options_exist() {
  if [ -n "$OPTIONS" ]; then
    options $OPTIONS $output
  else
    echo "Serial,ID,IP,Switch1,Port1,Switch2,Port2,State," >> $output
  fi
}
