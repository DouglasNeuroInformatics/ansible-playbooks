ansible-playbook -K -k -vv -i inventory initial-setup.yml --limit $1
ansible-playbook -vv -i inventory site.yml --limit $1
ansible-playbook -vv -i inventory update.yml --limit $1
ansible -b -m reboot all --limit ${1}
