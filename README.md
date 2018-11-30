# http-watch
## Brief Description
Monitors a URL, if the page goes offline it alerts via email and executes a command (typically to restart the web server).

It includes a wizard which helps to configure the program for you.


## Usage
Run: ```./wizard-http-watch.sh```

And it will present you with a GUI which will take information from you and program the config file for you.

Then run: ```./http-watch.sh```

To continually run the background use: ```./http-watch.sh &```

To have the program continually monitor

## Dev Notes
-- Work on handling a failure if it stays down
