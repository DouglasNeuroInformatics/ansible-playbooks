

#grid engine tools
gridengine-client
gridengine-qmon
gridengine-exec

#modules and profile
add source /etc/profile.d/modules.sh to /etc/profile

add
"""
# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
        # Shell is non-interactive.  Be done now!
        return
fi
"""
to /etc/profile.d/modules.sh

#Configuration tasks
grid engine
Email config (ssmtp, logwatch, apcupsd)
apcupsd
logcheck
configure IPMI
local scratch directory
enable sudo for devgab
automatic smart disk checking (/etc/default/smartmontools, /etc/smartd.conf, update-smart-drivedb)

CUPS (browsed.conf, printers.conf, PPDs)
