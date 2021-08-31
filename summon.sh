#!/bin/bash

# Function to get call for ease of use
source ./functions/add_to_csv.sh
source ./functions/getops_check.sh
source ./functions/options_validation.sh

# Loop: Get the next option, with silent error checking
while getopts ":h:t:f:o:" options; do

  # case to get flag items
  case "${options}" in
    h)
      HOST=${OPTARG}
      ;;
    t)
      TOKEN=${OPTARG}
      ;;
    f)
      FILENAME=${OPTARG}
      ;;
    o)
      OPTIONS=${OPTARG}
      ;;
  esac
done

# Check flag item variables to make sure that they are set
getopts_validate

# Creates file names for output and fail log
output=output_info_$(date +%F_%T).csv
faillog=fail_info_$(date +%F_%T).log


# Creates output and faillog files
> $output
> $faillog

# Function to validate that the options flag exists and is not empty
options_exist

# reads server serials list into array
IFS=$'\n' read -d '' -r -a serialsArr < $FILENAME

# Reads in column headers
IFS=',' read -r -a outputArr < $output

# loops through erials array
for i in "${serialsArr[@]}"
do
   # prints serial number
   echo "Running "$i"..."

   # runs summon command and parses output to correct json format. It outputs to temp.json
   summon physical find -t $TOKEN -s $i -h $HOST | sed -e 's/^.*summon: //p' > temp.json

   # removes first line which was keeping an extra bracket
   sed -i '.bak' 1d temp.json

   # Calls function to add items to the csv file
   add_to_csv

   # Clears variables
   ip=""
   sn=""
   id=""
   port=""
   port1=""
   port2=""
   switch1=""
   switch2=""
   state=""
done

# Removes Temporary Files
rm temp.json && rm temp.json.bak
if [ ! -s $faillog ] ; then
  rm $faillog
fi

# Opens table on command line
cat $output | sed 's/,/ ,/g' | column -t -s,

exit 0                                    # Exit normally.
