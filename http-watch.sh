#!/bin/bash

# Variables
COUNTER=1
DELAY=3
STATUSCODE=(`curl -s -o /dev/null -w "%{http_code}" http://www.eddxample.org/`)

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

while [ $COUNTER -le 3 ]
do
	echo "Running $COUNTER"
	if [ $STATUSCODE == "200" ]
	then
		echo "URL is online." && echo
		echo "Status code: 200" && echo
		echo "Exiting..." && echo
		exit 0
	fi
	sleep $DELAY
	((COUNTER++))
done

echo "URL is offline..." && echo
echo "Restarting Web Server..." && echo
service sshd status
