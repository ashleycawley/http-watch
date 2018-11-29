#!/bin/bash

# Variables
DOMAIN="http://status.ashleycawley.co.uk/online.html"
DELAY=10
NUMBEROFTRIES=3
SAVENUM=($NUMBEROFTRIES)
STATUSCODE=(`curl -s -o /dev/null -w "%{http_code}" $DOMAIN`)

export NEWT_COLORS='
window=,red
border=white,red
textbox=white,red
button=black,white
'

# Functions

# Script
#whiptail --title "http-watch" --msgbox "This wizard will help you implement monitoring of a URL and if it goes offline it can alert you and take action (restart your web server) for you." 8 78 Red

#whiptail --title "http-watch - URL" --inputbox "Enter the URL to monitor" 8 78

while [ $STATUSCODE == "200" ]
do
	echo "OK"	
	echo "Sleeping by $DELAY"
	sleep $DELAY

	echo "NUMBEROFTRIES = $NUMBEROFTRIES" # Debugging
	STATUSCODE=(`curl -s -o /dev/null -w "%{http_code}" $DOMAIN`)
	
	while [ $STATUSCODE != "200" ] && [ $NUMBEROFTRIES -gt 0 ]
	do
		echo "Test Failed - Retying..."
		echo "Sleeping by $DELAY" && sleep $DELAY
		STATUSCODE=(`curl -s -o /dev/null -w "%{http_code}" $DOMAIN`)
		((NUMBEROFTRIES--))
		echo "NUMBEROFTRIES = $NUMBEROFTRIES" # Debugging
	done
	if [ $NUMBEROFTRIES == "0" ]
	then
		echo "URL is offline..." && echo
		echo "Restarting Web Server..." && echo
		service sshd status	
	fi
	NUMBEROFTRIES=($SAVENUM)
done
