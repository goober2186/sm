#!/bin/bash

add_to_csv () {
  if [ "$(cat temp.json | jgrep -s id)" == "null" ]
    then
      echo "$i failed"
      echo $i >> $faillog
   else
       id=$(cat temp.json | jgrep -s id)
       sn=$(cat temp.json | jgrep -s serial_number)
       echo -n $sn"," >> $output
      for c in "${outputArr[@]}"
        do
          if [ "$c" == "ID" ]; then
            echo -n $id"," >> $output
          elif [ "$c" == "IP" ]; then
            ip=$(cat temp.json | jgrep -s ip)
            echo -n $ip"," >> $output
          elif [ "$c" == "Switch1" ]; then
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

            echo -n $switch1","$port1","$switch2","$port2"," >> $output
          elif [ "$c" == "State" ]; then
            # Temporary to get provisioner_state
            state=$(curl -sX GET "$HOST/api/compute/physicals/$id" -H  "accept: application/vnd.cerner.infra.v4" -H  "Authorization: Token token=$TOKEN" | sed -E 's/.*"provisioner_state":"?([^,"]*)"?.*/\1/')
            echo -n $state"," >> $output
          else
            :
          fi
   done
   echo "" >> $output
 fi
}
