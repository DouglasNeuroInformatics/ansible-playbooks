#!/usr/bin/env bash
# The following script is run when deploying / upgrading a machine. It should be run from the ansible-playbook directory.
# Ensure that the hostname that you run this on has already been added to the inventory file.

if [ "$#" -ne 1 ]; then
  echo "USAGE: bin/initial.sh <hostname>"
  exit 1
fi
set -euo pipefail

ansible-playbook -K -k -v -i inventory initial-setup.yml --limit $1
ansible-playbook -v -i inventory site.yml --limit $1 --ask-vault-password
ansible-playbook -v -i inventory update.yml --limit $1
ansible -b -m reboot all --limit ${1}
