#!/bin/bash

hitachiuser=$(echo "<replace with your Hitachi's account email in base64>" | base64 -d)
hitachipassword=$(echo "<replace with your Hitachi's account password in base64>" | base64 -d)
wssairCloud="wss://notification-global-prod.aircloudhome.com/rac-notifications/websocket"

uuid=$(curl -s https://www.uuidgenerator.net/api/version1)
#uuid=$(uuidgen)
token=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api-global-prod.aircloudhome.com" -H "User-Agent: okhttp/4.2.2" --data-binary "{\"email\":\"$hitachiuser\",\"password\":\"$hitachipassword\"}" --compressed "https://api-global-prod.aircloudhome.com/iam/auth/sign-in" | jq -r .token)
familyId=$(curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/json" -H "Accept: application/json" -H "Host: api-global-prod.aircloudhome.com" -H "User-Agent: okhttp/4.2.2" --compressed "https://api-global-prod.aircloudhome.com/iam/user/v2/who-am-i" | jq -r .familyId)
cloudlds=$(curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/json" -H "Accept: application/json" -H "Host: api-global-prod.aircloudhome.com" -H "User-Agent: okhttp/4.2.2" --compressed "https://api-global-prod.aircloudhome.com/rac/ownership/groups/cloudIds/$familyId")
connectandsub=$(printf "CONNECT\naccept-version:1.1,1.2\nheart-beat:10000,10000\nAuthorization:Bearer $token\n\n\0\nSUBSCRIBE\nid:$uuid\ndestination:/notification/$familyId/$familyId\nack:auto\n\n\0" | base64 -w0 )

if [ "$2" == "" ]
	then
		:
	else
		roomName=$2
		roomId=$(echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq -r ".data[] | select(.name==\"$roomName\") | .id")
fi

mode=$3
temperature=$4

case "$1" in
"on")
  now=$(date)
  #echo "ON at $now"  >> /opt/scripts/logs.txt
  until [ $(echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq -r ".data[] | select(.id==$roomId) | .power") = "ON" ]
  do
	echo "ON $mode $temperature at $now"  >> /opt/scripts/logs.txt
	curl -s -H "Authorization: Bearer $token" -H "Accept: application/json" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api-global-prod.aircloudhome.com" -H "User-Agent: okhttp/4.2.2" --data-binary "{\"fanSpeed\":\"AUTO\",\"fanSwing\":\"BOTH\",\"humidity\":\"50\",\"id\":$roomId,\"iduTemperature\":$temperature.0,\"mode\":\"$mode\",\"power\":\"ON\"}" -X PUT --compressed "https://api-global-prod.aircloudhome.com/rac/basic-idu-control/general-control-command/$roomId?familyId=$familyId"
	sleep 10
  done
;;
"off")
  now=$(date)
  #echo "OFF at $now" >> /opt/scripts/logs.txt
  until [ $(echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq -r ".data[] | select(.id==$roomId) | .power") = "OFF" ]
  do
	echo "OFF $mode $temperature at $now"  >> /opt/scripts/logs.txt
	curl -s -H "Authorization: Bearer $token" -H "Accept: application/json" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api-global-prod.aircloudhome.com" -H "User-Agent: okhttp/4.2.2" --data-binary "{\"fanSpeed\":\"AUTO\",\"fanSwing\":\"BOTH\",\"humidity\":\"50\",\"id\":$roomId,\"iduTemperature\":$temperature.0,\"mode\":\"$mode\",\"power\":\"OFF\"}" -X PUT --compressed "https://api-global-prod.aircloudhome.com/rac/basic-idu-control/general-control-command/$roomId?familyId=$familyId"
	sleep 10
  done
;;
"powerstatus")
	echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq -r ".data[] | select(.id==$roomId) | .power"
;;
"modestatus")
	echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq -r ".data[] | select(.id==$roomId) | .mode"
;;
"roomtemperature")
	echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq -r ".data[] | select(.id==$roomId) | .roomTemperature"
;;
"idutemperature")
	echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq -r ".data[] | select(.id==$roomId) | .iduTemperature"
;;
"websocatdebug")
	echo $connectandsub | $websocatbinary -b --base64 --ping-timeout=2 -q -n $wssairCloud | grep -a HITACHI | tr -d "\n" | jq
;;
*)
esac
