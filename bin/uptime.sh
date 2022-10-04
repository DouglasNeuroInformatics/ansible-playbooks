ansible -b -m shell -a 'echo $(hostname),$(uptime)' all -vv |& grep average
