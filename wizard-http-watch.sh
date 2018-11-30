#!/bin/bash

export NEWT_COLORS='
window=,red
border=white,red
textbox=white,red
button=black,white
'

#whiptail --title "http-watch" --msgbox "This wizard will help you implement monitoring of a URL and if it goes offline it can alert you and take action (restart your web server) for you." 8 78

# Gathers the URL to monitor from the user
SUPPLIEDURL=$(whiptail --inputbox "Enter the URL to monitor:" 8 78 http:// --title "HTTP-WATCH - URL" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
	sed -i s,URLPLACEHOLDER,$SUPPLIEDURL,g config
else
	echo "User selected Cancel." && exit 1
fi

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
        sed -i s,NUMBEROFTRIES,$SUPPLIEDRETRIES,g config
else
        echo "User selected Cancel." && exit 1
fi

# Gathers the desired action / command from the user
SUPPLIEDACTION=$(whiptail --inputbox "Enter the command you wish to execute upon failure:" 8 78 --title "HTTP-WATCH - Action" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
        sed -i s,ACTIONPLACEHOLDER,$SUPPLIEDACTION,g config
else
        echo "User selected Cancel." && exit 1
fi

## Reference ##
# URL="URLPLACEHOLDER"
# DELAY=DELAYPLACEHOLDER
# NUMBEROFTRIES=NUMBEROFTRIESPLACEHOLDER
# ACTION='ACTIONPLACEHOLDER'
