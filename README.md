# http-watch
## Brief Description
Monitors a URL, if the page goes offline it alerts via email and executes a command (typically to restart the web server).

It includes a wizard which helps to configure the program for you.

## Installation
Download this repo:

```git clone https://github.com/ashleycawley/http-watch.git```

```cd http-watch```

```./wizard-http-watch.sh```

And it will present you with a GUI which will take information from you and program the config file for you. Once you have completed the wizard run the following command to start http-watch in the background:

```./http-watch.sh &```

The **&** runs the script in the background which means you can leave the shell session and it will continue to monitor and act on your behalf.

## Dev Notes
-- Add in email alerting
-- Work on handling a failure if it stays down
