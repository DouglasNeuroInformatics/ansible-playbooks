#!/usr/bin/env bash

(for prefix in cicws dnpws cicss cicus cicvmhost ciccs; do
  for n in {01..50}; do
    nslookup ${prefix}${n} | tail -n +3 | grep -E '(Name:|Address:)' | awk -F'\t| +' '{print $2}' | paste -s -d,
  done
done
nslookup cicvmhost01 | tail -n +3 | grep -E '(Name:|Address:)' | awk -F'\t| +' '{print $2}' | paste -s -d,
nslookup cicbs | tail -n +3 | grep -E '(Name:|Address:)' | awk -F'\t| +' '{print $2}' | paste -s -d,
nslookup bruker7t | tail -n +3 | grep -E '(Name:|Address:)' | awk -F'\t| +' '{print $2}' | paste -s -d,
nslookup dnpus01 | tail -n +3 | grep -E '(Name:|Address:)' | awk -F'\t| +' '{print $2}' | paste -s -d,
) | sort | uniq

#| grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq


#| grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq
