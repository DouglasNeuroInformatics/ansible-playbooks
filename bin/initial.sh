#!/usr/bin/env bash
# The following script is run when deploying / upgrading a machine. It should be run from the ansible-playbook directory.
# Ensure that the hostname that you run this on has already been added to the inventory file.

if [ "$#" -ne 1 ]; then
  echo "USAGE: bin/initial.sh <hostname>"
  exit 1
fi
set -euo pipefail

hostname=${1}
ansible-playbook -K -k  -i inventory initial-setup.yml --limit "${hostname}"
ansible-playbook  -i inventory site.yml --limit "${hostname}" --ask-vault-password
ansible-playbook  -i inventory update.yml --limit "${hostname}"
ansible -b -m reboot all --limit "${hostname}"
