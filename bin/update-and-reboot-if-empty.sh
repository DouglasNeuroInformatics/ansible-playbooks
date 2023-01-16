#!/bin/bash

# [ $(who | grep -v -c localadmin) -eq 0 ] 


ansible -v -b -m shell -a '[ $(who | grep -v -c localadmin) -eq 0 ] && apt update && apt full-upgrade -y -o Dpkg::Options::="--force-confdef" && apt-get purge .*nvidia.* -y && apt-get --purge autoremove -y && ubuntu-drivers install && reboot' workstations
