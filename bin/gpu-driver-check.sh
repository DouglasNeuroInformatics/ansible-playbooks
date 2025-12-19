ansible -b -m shell -a 'echo $(hostname),$(dpkg -l | grep -o -E "nvidia-driver-[0-9]+"),$(lspci | grep VGA)' workstations | grep -E '^(cicws|dnpws).*VGA.*'
