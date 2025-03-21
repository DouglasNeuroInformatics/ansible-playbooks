#!/usr/bin/env bash

ansible -b -m shell -a 'jc ping -q -w 60 -A ad01.douglas.rtss.qc.ca' workstations \
 | jq '[.plays[].tasks[].hosts | to_entries[] | {host: .key, output: (.value.stdout? // "" | fromjson? //  null)}]' \
 | tee output.json

