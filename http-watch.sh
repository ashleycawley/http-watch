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
echo "Pasung for $DELAY seconds" && sleep $DELAY
}

function NORESPONSE {
echo "Error: URL Not Responding"
}

function TAKEACTION {
$ACTION
}

# Script

echo -e "\nHTTP-WATCH is monitoring: $URL"

TESTURL # Performs intial test to see if URL is online and get its status code

if [ $STATUSCODE != "200" ]
then
	echo "Error: $URL appears to be offline. Please provide me with an alternative URL which is online."
	read -p "URL: " URL
	TESTURL # Tests the URL supplied by the user and returns 200 (OK) status code or nothing
fi

while [ $STATUSCODE == "200" ]
do
	echo "200 - OK"	
	PAUSE # Pauses for x number of seconds (specified by the user)
	ECHORETRIES # Debugging
	TESTURL # Tests the URL supplied by the user and returns 200 (OK) status code or nothing
	
	while [ $STATUSCODE != "200" ] && [ $NUMBEROFTRIES -gt 0 ]
	do
		NORESPONSE # Debugging
		PAUSE
		TESTURL
		((NUMBEROFTRIES--))
		ECHORETRIES # Debugging
	done
	if [ $NUMBEROFTRIES == "0" ]
	then
		NORESPONSE # Debugging
		$ACTION	
		echo && echo "Service Restarted, pausing for 30 seconds before retrying..."
		sleep 30
		TESTURL
	fi
	NUMBEROFTRIES=($SAVENUM) # Resets the NUMBEROFTRIES counter backs to its original number
done
