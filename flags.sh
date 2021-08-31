#!/bin/bash

# Initializes flag variables
HOST=""
TOKEN=""
FILENAME=""

# Exits on error
exit_abnormal() {
  exit 1
}

# Loop: Get the next option, with silent error checking
while getopts ":h:t:f:" options; do

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
  esac
done

# Check flag item variables to make sure that they are set

if [ -z "$HOST" ] || [ -z "$TOKEN" ] || [ -z "$FILENAME" ]; then
  if [ -z "$HOST" ]; then
    echo "Missing -h <closedstack url>"
    echo "summon.sh -h <url> -t <closedstack api token> -f <path to server list file>"
    exit_abnormal

  elif [ -z "$TOKEN" ]; then
    echo "Missing -t <token>"
    echo "summon.sh -h <url> -t <closedstack api token> -f <path to server list file>"
    exit_abnormal

  elif [ -z "$FILENAME" ]; then
    echo "Missing -f <path to server list file>"
    echo "summon.sh -h <url> -t <closedstack api token> -f <path to server list file>"
    exit_abnormal
  fi
fi

# reads server list into array
IFS=$'\n' read -d '' -r -a lines < $FILENAME

# Creates files for output and fail log
output=output_info_$(date +%F_%T).csv
faillog=fail_info_$(date +%F_%T).log

# sets up the output.csv column headers
echo "ID,Serial,IP,Switch1,Port1,Switch2,Port2,State," > $output
> $faillog

# loops through lines array
for i in "${lines[@]}"
do

   # prints serial number
   echo "Running "$i"..."

   # runs summon command and parses output to correct json format. It outputs to temp.json
   summon physical find -t $TOKEN -s $i -h $HOST | sed -e 's/^.*summon: //p' > temp.json

   # removes first line which was keeping an extra bracket
   sed -i '.bak' 1d temp.json

   # Checks to see if ID exists if not outputs to fail.txt
   if [ "$(cat temp.json | jgrep -s id)" == "null" ]
     then
       echo "$i failed"
       echo $i >> $faillog
     else

          # parses the json values by key in the temp.json file
          ip=$(cat temp.json | jgrep -s ip)
          sn=$(cat temp.json | jgrep -s serial_number)
          id=$(cat temp.json | jgrep -s id)
          switch=$(cat temp.json | jgrep -s switches.name)
          port=$(cat temp.json | jgrep -s switches.port)

          # Puts switch names into an array to split
          portArray=($port)
          port1=${portArray[0]}
          port2=${portArray[1]}

          # Puts switch names into an array to split
          switchArray=($switch)
          switch1=${switchArray[0]}
          switch2=${switchArray[1]}


          # Temporary to get provisioner_state
          state=$(curl -sX GET "$HOST/api/compute/physicals/$id" -H  "accept: application/vnd.cerner.infra.v4" -H  "Authorization: Token token=$TOKEN" | sed -E 's/.*"provisioner_state":"?([^,"]*)"?.*/\1/')
          # appends parsed values to output.csv
          echo $id","$sn","$ip","$switch1","$port1","$switch2","$port2","$state >> $output
   fi

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
cat $output | column -t -s,

exit 0                                    # Exit normally.
