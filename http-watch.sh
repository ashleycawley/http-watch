#!/bin/bash

# Imports variables from a config file
source ./config

# Variables
SAVENUM=($NUMBEROFTRIES)

# Functions
function TESTURL {
STATUSCODE=(`curl -s -o /dev/null -w "%{http_code}" $URL`)
}

function ECHORETRIES {
echo "NUMBEROFTRIES = $NUMBEROFTRIES" # Debugging
}

function PAUSE {
sleep $DELAY
}

function NORESPONSE {
echo "Error: URL Not Responding"
}

# Script

echo -e "\nHTTP-WATCH is monitoring: $URL"

TESTURL # Performs intial test to see if URL is online and get its status code

while [ $STATUSCODE == "200" ]
do
	# echo "200 - OK" # Debugging
	PAUSE # Pauses for x number of seconds (specified by the user)
	#ECHORETRIES # Debugging
	TESTURL # Tests the URL supplied by the user and returns 200 (OK) status code or nothing
	
	while [ $STATUSCODE != "200" ] && [ $NUMBEROFTRIES -gt 0 ]
	do
		#NORESPONSE # Debugging
		#ECHORETRIES # Debugging
		PAUSE
		TESTURL
		((NUMBEROFTRIES--))
	done

	if [ $NUMBEROFTRIES == "0" ]
	then
		#NORESPONSE # Debugging
		$ACTION	
		echo && echo "Service Restarted, pausing for $DELAY seconds before retrying..."
		PAUSE
		TESTURL
		if [ $STATUSCODE != "200" ]
		then
			STATE=false
		fi
		
		while [ $STATE == "false" ]
		do
			$ACTION
			PAUSE
			TESTURL
			if [ $STATUSCODE == "200" ]
			then
				STATE=true
			fi
		done
	fi
	NUMBEROFTRIES=($SAVENUM) # Resets the NUMBEROFTRIES counter backs to its original number
done

