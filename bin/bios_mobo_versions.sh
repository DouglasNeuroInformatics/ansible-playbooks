#ansible -v -b -m shell -a 'echo $(hostname),$(lshw -json | jq ".children[0].product"),$(lshw -json | jq ".children[0].children[0].version"),$(lshw -json | jq ".children[0].serial")' all | grep -E -o '(cic|dnp)(ws|cs)[0-9]+,.*' | sort

ANSIBLE_LOAD_CALLBACK_PLUGINS=1 ANSIBLE_STDOUT_CALLBACK=json \
ansible all -m setup -t json | \
 jq -r '.plays[].tasks[].hosts[] |
       [.ansible_facts.ansible_nodename,
        .ansible_facts.ansible_board_vendor,
        .ansible_facts.ansible_board_name,
        .ansible_facts.ansible_bios_version,
        .ansible_facts.ansible_bios_date ] | @csv'
