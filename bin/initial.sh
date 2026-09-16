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

# A freshly provisioned machine has no admin key in localadmin's
# authorized_keys yet -- initial-setup.yml is what puts it there -- so this
# first connection has to authenticate with a password. -k prompts for the
# login password and -K for the sudo password.
#
# ansible.cfg pins PreferredAuthentications=publickey so routine runs stay
# key-only. OpenSSH honours the first value it sees for an option and Ansible
# prepends ssh_args ahead of its own flags, so that setting would veto the
# password auth -k asks for. Widen the list for the bootstrap run alone; the
# config is left untouched, so site.yml and update.yml below remain key-only.
#
# ANSIBLE_SSH_ARGS replaces ssh_args wholesale rather than adding to it, and
# control_path only applies when ControlMaster/ControlPersist are present, so
# the multiplexing options are repeated here to keep connection reuse.
# publickey stays first: re-running this on an already-bootstrapped machine
# still authenticates with the key.
ANSIBLE_SSH_ARGS='-o ControlMaster=auto -o ControlPersist=60m -o PreferredAuthentications=publickey,keyboard-interactive,password' \
  ansible-playbook -K -k -i inventory initial-setup.yml --limit "${hostname}"

# The bootstrap above installed the admin keys, so everything from here on
# authenticates with the key material and needs neither -k nor -K.
ansible-playbook  -i inventory site.yml --limit "${hostname}" --tags all,snipeit
ansible-playbook  -i inventory update.yml --limit "${hostname}"
ansible -b -m reboot all --limit "${hostname}"
