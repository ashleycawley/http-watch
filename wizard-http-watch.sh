#!/bin/bash

# Variables
STATE=false

# Functions
function TESTURL {
STATUSCODE=(`curl -s -o /dev/null -w "%{http_code}" $SUPPLIEDURL`)
}

# Script

whiptail --title "http-watch" --msgbox "This wizard will help you implement monitoring of a URL and if it goes offline it can alert you and take action (restart your web server) for you." 8 78

# Clears any old config
rm -f config

# Copies blank template in to position to be re-written and editted by the commands below
cp config-template config

while [ $STATE == "false" ]
do
	# Gathers the URL to monitor from the user
	SUPPLIEDURL=$(whiptail --inputbox "Enter the URL to monitor:" 8 78 http:// --title "HTTP-WATCH - URL" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		sed -i s,URLPLACEHOLDER,$SUPPLIEDURL,g config

		TESTURL

		if [ $STATUSCODE == "200" ]
		then
			STATE=true
		fi

		if [ $STATUSCODE != "200" ]
		then
			if (whiptail --title "URL Offline" --yesno "The URL you provided appears to be offline, are you sure you still want to proceed?" 8 78); then
				STATE=true	
			else
				STATE=false
			fi

		fi
	else
		echo "User selected Cancel." && exit 1
	fi
done

# Gathers the delay in seconds from the user
SUPPLIEDDELAY=$(whiptail --inputbox "Enter the delay in seconds between the tests:" 8 78 30 --title "HTTP-WATCH - Delay in Seconds" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
        sed -i s,DELAYPLACEHOLDER,$SUPPLIEDDELAY,g config
else
        echo "User selected Cancel." && exit 1
fi

# Gathers the number of retries from the user
SUPPLIEDRETRIES=$(whiptail --inputbox "Enter the number of retries after failure:" 8 78 3 --title "HTTP-WATCH - Number of Retries" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
        sed -i s,NUMBEROFTRIESPLACEHOLDER,$SUPPLIEDRETRIES,g config
else
        echo "User selected Cancel." && exit 1
fi

# Gathers the desired action / command from the user
SUPPLIEDACTION=$(whiptail --inputbox "Enter the command you wish to execute upon failure:" 8 78 --title "HTTP-WATCH - Action" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
        sed -i "s,ACTIONPLACEHOLDER,$SUPPLIEDACTION,g" config
else
        echo "User selected Cancel." && exit 1
fi

SUPPLIEDEMAIL=$(whiptail --inputbox "Email address to be notified:" 8 78 --title "HTTP-WATCH - Email" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
        sed -i "s,EMAILPLACEHOLDER,$SUPPLIEDEMAIL,g" config
else
	echo "User selected Cancel." && exit 1
fi

# Testing for whiptail.
#SUPPLIEDURL=""
#SUPPLIEDDELAY="3"
#SUPPLIEDRETRIES="3"
#SUPPLIEDACTION="service apache2 restart"
#SUPPLIEDEMAIL=""

CONFIRM='                              Is the supplied information correct?

                            ========================================

                              URL:               '$SUPPLIEDURL'
                              DELAY SET:         '$SUPPLIEDDELAY'
                              RETRY LIMIT:       '$SUPPLIEDRETRIES'
                              ACTION SET:        '$SUPPLIEDACTION'
                              EMAIL SET:         '$SUPPLIEDEMAIL''

if (whiptail --title "HTTP-Wizard - Confirm Config" --yesno "$CONFIRM" 25 100)
then
	whiptail --title "HTTP-Wizard - Config Saved!" --msgbox "The config file has now been saved!" 8 78
else
	if (whiptail --title "HTTP-Wizard - Start over?" --yesno "Would you like to restart the script?" 8 78)
	then
		clear
		./wizard-http-watch.sh
	else
		if (whiptail --title "HTTP-Wizard - Delete current config?" --yesno "Would you like to delete the current config?" 8 78)
		then
			rm -f config
			whiptail --title "HTTP-Wizard - Config Deleted!" --msgbox "Config file has been deleted!" 8 78
			exit 0
		else
			whiptail --title "HTTP-Wizard - Config Saved!" --msgbox "Config files has been saved!" 8 78
		fi
	fi
fi

if (whiptail --title "HTTP-Watch - Start the script?" --yesno "Would you like to start the main script? (http-watch.sh)" 8 78)
then
	echo "Closing wizard-http-watch.sh.."
	./http-watch.sh &
	exit 0
else
	whiptail --title "HTTP-Wizard - Script finished!" --msgbox "The script has completed! I will not start http-watch..." 8 78
	exit 0
fi

## Reference ##
# URL="URLPLACEHOLDER"
# DELAY=DELAYPLACEHOLDER
# NUMBEROFTRIES=NUMBEROFTRIESPLACEHOLDER
# ACTION='ACTIONPLACEHOLDER'
