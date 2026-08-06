#!/usr/bin/env bash
# The following script is run when deploying / upgrading a machine. It should be run from the ansible-playbook directory.
# Ensure that the hostname that you run this on has already been added to the inventory file.

if [ "$#" -ne 1 ]; then
  echo "USAGE: bin/initial.sh <hostname>"
  exit 1
fi
set -euo pipefail

hostname=${1}

# ansible.cfg points at ./.vault_pass, which is gitignored and so is absent on a
# fresh clone. Prompt for it rather than failing partway through the run.
if [ ! -f .vault_pass ]; then
  vault_pass_file=$(mktemp)
  trap 'rm -f "${vault_pass_file}"' EXIT
  export ANSIBLE_VAULT_PASSWORD_FILE="${vault_pass_file}"

  read -rsp "Vault password: " vault_pass
  echo
  printf '%s' "${vault_pass}" > "${vault_pass_file}"
  unset vault_pass

  if ! ansible-vault view group_vars/all/vault.yml > /dev/null; then
    echo "Vault password is incorrect." >&2
    exit 1
  fi
fi

ansible-playbook -K -k  -i inventory initial-setup.yml --limit "${hostname}"
ansible-playbook  -i inventory site.yml --limit "${hostname}" --tags all,snipeit
ansible-playbook  -i inventory update.yml --limit "${hostname}"
ansible -b -m reboot all --limit "${hostname}"
