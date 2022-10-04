#!/bin/bash

# [ $(who | grep -v -c localadmin) -eq 0 ] 


ansible -v -b -m shell -a '[ $(who | grep -v -c localadmin) -eq 0 ] && reboot' workstations
