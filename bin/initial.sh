#!/usr/bin/env bash
# The following script is run when deploying / upgrading a machine. It should be run from the ansible-playbook directory.
# Ensure that the hostname that you run this on has already been added to the inventory file.

if [ "$#" -ne 1 ]; then
  echo "USAGE: bin/initial.sh <hostname>"
  exit 1
fi
set -euo pipefail

hostname=${1}
echo ansible-playbook -K -k -v -i inventory initial-setup.yml --limit "${hostname}"
echo ansible-playbook -v -i inventory site.yml --limit "${hostname}" --ask-vault-password
echo ansible-playbook -v -i inventory update.yml --limit "${hostname}"
echo ansible -b -m reboot all --limit "${hostname}"
