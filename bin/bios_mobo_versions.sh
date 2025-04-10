#!/usr/bin/env bash

ANSIBLE_LOAD_CALLBACK_PLUGINS=1 ANSIBLE_STDOUT_CALLBACK=json \
ansible all -m setup | \
 jq -r '.plays[].tasks[].hosts[] |
       [.ansible_facts.ansible_nodename,
        .ansible_facts.ansible_board_vendor,
        .ansible_facts.ansible_board_name,
        .ansible_facts.ansible_bios_version,
        .ansible_facts.ansible_bios_date ] | @csv'
