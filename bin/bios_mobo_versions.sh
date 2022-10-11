ansible -v -b -m shell -a 'echo $(hostname),$(lshw -json | jq ".children[0].product"),$(lshw -json | jq ".children[0].children[0].version")' all | grep -E '(cic|dnp)ws[0-9]+,'
