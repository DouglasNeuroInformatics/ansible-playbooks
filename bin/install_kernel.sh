#!/bin/bash

set -euo pipefail
set -x

export DEBIAN_FRONTEND=noninteractive

# Stolen from xanmod website and modified to generate version to install
check_abi_awkscript='
BEGIN {
    while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
    if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
    if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
    if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
    if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
    if (level > 0) { print "x64v" level; exit 0 }
    exit 0
}'

apt-mark unhold "*" >/dev/null 2>&1

apt-get purge '*nvidia*' '*xanmod*' '*zabbly*' dkms -y --autoremove || true

rm -rf /var/lib/dkms

nvidia_driver_version=$((ubuntu-drivers list || true) | grep -v server | (grep -o -E 'nvidia-driver-(390|570)' || true) | sort  | tail -1) || true

x64_version=$(awk "${check_abi_awkscript}" || echo 1)

add-apt-repository ppa:kisak/turtle -y
apt full-upgrade -y


if [[ ${nvidia_driver_version} == "nvidia-driver-390" ]]; then
  # We have to special case this because the 390 driver won't work on the latest kernel (yet...)
  # apt install -y linux-xanmod-lts-${x64_version} dkms
  # apt install -y ${nvidia_driver_version}
  # apt install -y $(echo ${nvidia_driver_version} | sed 's/driver/dkms/g')
  apt install -y linux-xanmod-${x64_version}
elif [[ ${nvidia_driver_version} == "nvidia-driver-570" ]]; then
  apt install -y linux-xanmod-${x64_version} dkms
  apt install -y ${nvidia_driver_version}
  apt install -y $(echo ${nvidia_driver_version} | sed 's/driver/dkms/g')
else
  apt install -y linux-xanmod-${x64_version}
fi

apt-get --purge autoremove -y

if [[ -s /usr/lib/dkms/dkms_autoinstaller ]]; then
  ls /boot/initrd.img-* | cut -d- -f2- | \
      xargs -n1 /usr/lib/dkms/dkms_autoinstaller start || true
fi

apt-mark hold 'linux*' "*nvidia*" >/dev/null 2>&1
