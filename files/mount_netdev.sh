#!/bin/bash

# Have to ping the NFS server to know when the network is actually configured
# This is the only way to use /etc/fstab although you may be better off using Autofs Automounter instead
# It's just a limitation of NFS and Linux booting.  If your network was Wifi you'd have this problem even worse
# It may take a few seconds after boot (you get a login prompt on your local console) before this gets to mount too
while [ ping cicus03 -c 2 2>/dev/null >/dev/null ]
do
        sleep 1
done

mount /opt/sge/default
mount /opt/quarantine

/etc/init.d/sgeexecd.p6444 restart
exit 0
