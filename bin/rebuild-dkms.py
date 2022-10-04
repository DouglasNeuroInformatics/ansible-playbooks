#!/usr/bin/env python3
#
# NOTE: This assumes that all modules and versions are built for at
#       least one kernel. If that's not the case, adapt parsing as needed.
import os
import subprocess
import re

# Permission check.
if os.geteuid() != 0:
    print("You need to be root to run this script.")
    exit(1)

# Get DKMS status output.
cmd = ['dkms', 'status']
dkms_status = subprocess.run(cmd, stdout=subprocess.PIPE).stdout.decode("utf-8").strip('\n').split('\n')
dkms_status = [re.split(', |/', x) for x in dkms_status]

##
# Get kernel versions (probably crap).
#cmd = ['ls', '/var/lib/initramfs-tools/']  # Does not work on Ubuntu 22.04
# Alternative (for use with Arch Linux for example)
# cmd = ['ls', '/usr/lib/modules/']
#kernels = subprocess.run(cmd, stdout=subprocess.PIPE).stdout.decode("utf-8").strip('\n').split('\n')
##

## Works on 22.04
prefix = 'initrd.img-'
kernels = [k[len(prefix):] for k in os.listdir('/boot')
           if k.startswith(prefix)]
##

# Parse output, 'modules' will contain all modules pointing to a set
# of versions.
modules = {}

for entry in dkms_status:
   module = entry[0]
   version = entry[1].split(': ')[0]
   try:
      modules[module].add(version)
   except KeyError:
      # We don't have that module, add it.
      modules[module] = set([version])

# For each module, build all versions for all kernels.
for module in modules:
   for version in modules[module]:
      for kernel in kernels:
         for action in ['remove', 'install']:
            cmd = ['dkms', action, '-m', module, '-v', version, '-k', kernel]
            subprocess.run(cmd)
