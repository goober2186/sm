#!/bin/bash

# Check flag item variables to make sure that they are set
getopts_validate() {
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
}

# Exits on getops error
exit_abnormal() {
  exit 1
}
