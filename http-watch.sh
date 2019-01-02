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

function DATE {
log_name_date=`date +'%Y-%m-%d'`
}

# Pre-Script Checks

if [ ! -d "$LOG_PATH" ] # Check to see if the path exists
then
	mkdir -p $LOG_PATH # If it does not, create the path from the config
fi

touch log_$log_name_date.txt $LOG_PATH # Create a new log file
log_file=$LOG_PATH/log_$log_name_date.txt # Specify the path used to write

# Script

echo "----- http-watch log file for: $URL -----"$'\r' > $log_file # New header 
log_get_exe_date=`date '+%Y-%m-%d %H:%M:%S'` # Get current time with Hours, Mins, Seconds
log_get_user=`whoami` # Get the user who executed the script
echo "Script executed: $log_get_exe_date" >> $log_file # Write execute time to log
echo "User running: $log_get_user" >> $log_file # Write user that executed the script to the log

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
		echo "$log_running_date - $URL is offline... Trying again..." >> $log_file
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
		echo "$log_running_date - Action was needed because the $URL was offline, command that was executed: $ACTION" >> $log_file

		# Dispatch Email Alert
		LOG_DATE
		echo -e "[http-watch] reporting from `hostname` at `date` \n \nDetected that $URL was offline.\n \nThe following action was taken: $ACTION" | mail -s "[http-watch] $URL" $EMAIL
		echo "$log_running_date - Email was dispatched to: $EMAIL" >> $log_file

		LOG_DATE
		echo && echo "Service Restarted, pausing for $DELAY seconds before retrying..."
		echo "$log_running_date - Service was restarted..." >> $log_file
		PAUSE
		TESTURL
		if [ $STATUSCODE != "200" ]
		then
			LOG_DATE
			STATE=false
			echo "$log_running_date - $URL is still offline..." >> $log_file
		fi
		
		while [ $STATE == "false" ]
		do	
			LOG_DATE
			$ACTION
			echo "$log_running_date - $URL is still offline... Re-running action command..." >> $log_file
			PAUSE
			TESTURL
			if [ $STATUSCODE == "200" ]
			then
				LOG_DATE
				STATE=true
				echo "$log_running_date - $URL is back online!" >> $log_file
			fi
		done
	fi
	NUMBEROFTRIES=($SAVENUM) # Resets the NUMBEROFTRIES counter backs to its original number
done
