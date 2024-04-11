#!/bin/bash

# Stolen from xanmod website and modified to generate version to install
check_abi_awkscript='
BEGIN {
    while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
    if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
    if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
    if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
    if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
    if (level > 0) { print "x64v" level; exit level + 1 }
    exit 0
}'

apt-mark unhold "linux*" "*nvidia*" >/dev/null 2>&1

ubuntu-drivers install

nvidia_driver=$(dpkg -l | grep -o -E 'nvidia-driver-[0-9]+' || true)
x64_version=$(awk "${check_abi_awkscript}" || true)

if [[ ${nvidia_driver} == "nvidia-driver-390" ]]; then
  # We have to special case this because the 390 driver won't work on the latest kernel (yet...)
  apt install -y linux-xanmod-lts-${x64_version}
  apt install -y linux-generic linux-generic-hwe-22.04 linux-generic-hwe-22.04-edge
  apt install -y $(echo ${nvidia_driver} | sed 's/driver/dkms/g')
elif [[ -n ${nvidia_driver} ]]; then
  apt install -y linux-generic linux-generic-hwe-22.04 linux-generic-hwe-22.04-edge linux-xanmod-${x64_version}
  apt install -y $(echo ${nvidia_driver} | sed 's/driver/dkms/g')
else
  apt install -y linux-generic linux-generic-hwe-22.04 linux-generic-hwe-22.04-edge linux-xanmod-${x64_version}
fi

ls /boot/initrd.img-* | cut -d- -f2- | \
    xargs -n1 /usr/lib/dkms/dkms_autoinstaller start || true

apt-mark hold 'linux*' "*nvidia*" >/dev/null 2>&1
