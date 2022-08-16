#!/bin/bash
set -euo pipefail
ansible-playbook -K -k -v -i inventory initial-setup.yml --limit $1
ansible-playbook -v -i inventory site.yml --limit $1
ansible-playbook -v -i inventory update.yml --limit $1
ansible -b -m reboot all --limit ${1}
