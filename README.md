ansible-playbooks
=================
Playbooks which setup NVIDIA-based workstations at the Douglas CIC

It is important to run ./initial.sh first, as password-based ansible is flaky, so setup all keys and passwordless sudo first.

## Vault password

`group_vars/all/vault.yml` and `vars/secrets.yml` are vault-encrypted. `ansible.cfg`
reads the password from `./.vault_pass`, which is gitignored and therefore missing
after a fresh clone — create it before running playbooks directly:

```sh
$ printf '%s' 'the-vault-password' > .vault_pass && chmod 600 .vault_pass
```

`bin/initial.sh` prompts for the password if the file is absent.

## Dependencies

```sh
$ ansible-galaxy role install bodsch.snapd mambaorg.micromamba
```
