#!/bin/bash

# Create a lock file to ensure the welcome popup message runs only once per user on system startup
LOCKFILE="/tmp/login_message_${USER}.lock"

if [ "$DISPLAY" ] && [ ! -e "$LOCKFILE" ]
then
	touch "$LOCKFILE"
	/usr/local/bin/dnp-xsession-welcome.sh
fi
