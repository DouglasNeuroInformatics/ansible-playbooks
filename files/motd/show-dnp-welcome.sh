#!/bin/bash

# Create a lock file to ensure the welcome popup message runs only once per user on system startup
LOCKFILE="/tmp/login_message_${USER}.lock"

if [ "$DISPLAY" ] && [ ! -e "$LOCKFILE" ] && [ "$EUID" -ne 0 ] && [[ -z ${SSH_TTY} ]]; then
  touch "$LOCKFILE"
  /usr/local/bin/dnp-xsession-welcome.sh
fi
