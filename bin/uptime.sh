#!/usr/bin/env bash


# Should be replaced with an ansible -m setup call
ansible -m shell -a 'echo $(hostname),$(uptime)' all -vv |& grep average
