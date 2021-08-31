#!/usr/bin/env bash

# Initializes flag variables
HOST=""
TOKEN=""
FILENAME=""
TEMPLATE=""

# Exits on error
exit_abnormal() {
  exit 1
}

# Loop: Get the next option, with silent error checking
while getopts ":h:t:f:j:" options; do

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
    j)
      TEMPLATE=${OPTARG}
      ;;
  esac
done

# Check flag item variables to make sure that they are set

if [ -z "$HOST" ] || [ -z "$TOKEN" ] || [ -z "$FILENAME" ] || [ -z "$TEMPLATE" ]; then
  if [ -z "$HOST" ]; then
    echo "Missing -h <closedstack url>"
    echo "provision.sh -h <url> -t <closedstack api token> -f <path to server list file> -t <json template>"
    exit_abnormal

  elif [ -z "$TOKEN" ]; then
    echo "Missing -t <token>"
    echo "provision.sh -h <url> -t <closedstack api token> -f <path to server list file> -t <json template>"
    exit_abnormal

  elif [ -z "$FILENAME" ]; then
    echo "Missing -f <path to server list file>"
    echo "provision.sh -h <url> -t <closedstack api token> -f <path to server list file> -t <json template>"
    exit_abnormal

  elif [ -z "$TEMPLATE" ]; then
    echo "Missing -t <path to server list file>"
    echo "provision.sh -h <url> -t <closedstack api token> -f <path to server list file> -t <json template>"
    exit_abnormal
  fi
fi

# reads server list into array
IFS=$'\n' read -d '' -r -a lines < $FILENAME


# creates timestamped files
output=output_provision_$(date +%F_%T).csv
faillog=fail_provision$(date +%F_%T).log

# sets up the output.csv column headers
echo "ID,Serial,Job_ID" > $output

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
          sn=$(cat temp.json | jgrep -s serial_number)
          id=$(cat temp.json | jgrep -s id)

          # Gets to get job_id
          jid=$(curl -X POST "$HOST/api/compute/physicals/$id/provision;" -H  "accept: application/vnd.cerner.infra.v3" -H  "Content-Type: application/json" -H  "Authorization: Token token=$TOKEN" -d @$TEMPLATE | sed -E 's/.*"job_id":"?([^,"]*)"?.*/\1/')
          # appends parsed values to output.csv
          echo $id","$sn","$jid"," >> $output
   fi

   # Clears variables
   sn=""
   id=""
   jid=""
done
# Removes Temporary Files
rm temp.json && rm temp.json.bak

# Opens table on command line
cat output.csv | column -t -s,
