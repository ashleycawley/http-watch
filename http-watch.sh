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

function LOG_DATE {
log_running_date=`date '+%Y-%m-%d %H:%M:%S'`
}

# Pre-Script Checks

SCRIPT_NAME=`basename "$0"` # Get script name
GET_PID=$(pidof -x "$SCRIPT_NAME") # Check the script name to see if it is running
if [ $GET_PID == $$ ] 2> /dev/null # If the process ID is the same as this instance
then
	sleep 1 # Wait for 1 second
else
	GET_PID=${GET_PID//$$/} # Remove it's own instance from $GET_PID
	whiptail --title "http-watch.sh - Script already running!" --msgbox "http-watch is already running! Please stop the other instance before continuing.. The process ID: $GET_PID" 8 78 # Display message box and show the other process Id
	exit 1 # Quit the script 
fi

if [ ! -d "$LOG_PATH" ] # Check to see if the path exists
then
	mkdir -p $LOG_PATH # If it does not, create the path from the config
fi

touch $LOG_PATH/http-watch.log  # Create a new log file
LOG_FILE=$LOG_PATH/http-watch.log # Specify the path used to write

# Script

echo "----- http-watch log file -----" >> $LOG_FILE # New header 
LOG_DATE # Get current time with Hours, Mins, Seconds
echo "Script executed: $log_running_date" >> $LOG_FILE # Write execute time to log
echo "User running: `whoami`" >> $LOG_FILE # Write user that executed the script to the log
echo "HTTP-WATCH is monitoring: $URL" >> $LOG_FILE # Write the URL which is being watched

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
		LOG_DATE
		echo "$log_running_date - $URL is offline... Trying again..." >> $LOG_FILE
		#NORESPONSE # Debugging
		#ECHORETRIES # Debugging
		PAUSE
		TESTURL
		((NUMBEROFTRIES--))
	done

	if [ $NUMBEROFTRIES == "0" ]
	then
		LOG_DATE
		#NORESPONSE # Debugging
		$ACTION	
		echo "$log_running_date - Action was needed because the $URL was offline, command that was executed: $ACTION" >> $LOG_FILE

		# Dispatch Email Alert
		LOG_DATE
		echo -e "[http-watch] reporting from `hostname` at `date` \n \nDetected that $URL was offline.\n \nThe following action was taken: $ACTION" | mail -s "[http-watch] $URL" $EMAIL
		echo "$log_running_date - Email was dispatched to: $EMAIL" >> $LOG_FILE

		LOG_DATE
		echo && echo "Action was taken, pausing for $DELAY seconds before retrying..."
		echo "$log_running_date - Action was taken... ($ACTION)" >> $LOG_FILE
		PAUSE
		TESTURL
		if [ $STATUSCODE == "200" ]
		then
			LOG_DATE
			echo "$log_running_date - $URL is back online..." >> $LOG_FILE
		elif [ $STATUSCODE != "200" ]
		then
			LOG_DATE
			STATE=false
			echo "$log_running_date - $URL is still offline..." >> $LOG_FILE
		fi
		
		while [[ $STATE == "false" ]]
		do	
			LOG_DATE
			$ACTION
			echo "$log_running_date - $URL is still offline... Re-running action command..." >> $LOG_FILE
			PAUSE
			TESTURL
			if [ $STATUSCODE == "200" ]
			then
				LOG_DATE
				STATE=true
				echo "$log_running_date - $URL is back online!" >> $LOG_FILE
			fi
		done
	fi
	NUMBEROFTRIES=($SAVENUM) # Resets the NUMBEROFTRIES counter backs to its original number
done
