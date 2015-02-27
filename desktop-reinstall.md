#packages
xauth
lm-sensors
thermald
tmux
screen
apcupsd
logwatch
landscape-common
ssmtp
unattended-upgrades
acpi-call-dkms
lvm2
exfat-utils
graphicsmagick-imagemagick-compat
ubuntu-zfs
irssi
openssh-server
ansible
environment-modules
quota
parallel
cvs
subversion
ruby
ruby-dev
make
gcc
nodejs
build-essential
gfortran
git
aptitude
intel-microcode
libnss-myhostname
mesa-utils
nmap
oracle-java7-installer
lrzip
htop
iotop
p7zip-rar
p7zip-full
unace
unrar
zip
unzip
sharutils
rar
uudeview
mpack
arj
cabextract
gdebi
dkms
python-numpy
python-scipy
python-matplotlib
ipython
ipython-notebook
python-pandas
python-sympy
python-nose
python-scitools
vim
ctags
vim-doc
vim-scripts
fonts-inconsolata
octave
pspp
emacs
git
xfsprogs
reiserfsprogs
reiser4progs
ntfs-3g
dosfstools
dmraid
dmsetup
kpartx
freeipmi


#nis
nscd
nis

#libraries
ubuntu-restricted-addons
ubuntu-restricted-extras
freeglut3
freeglut3-dev
cmake
cmake-curses-gui
protobuf-c-compiler
protobuf-compiler
python-protobuf
netcdf-bin
libnetcdf-dev
libnetcdfc7
libnetcdff5
libnetcdfc++4
libhdf4-0
libhdf4-dev
libhdf5-7
libhdf5-dev
lib32gcc1

#grid engine tools
gridengine-client
gridengine-qmon
gridengine-exec

#gem install
jekyll
github-pages

#modules and profile
add source /etc/profile.d/modules.sh to /etc/profile

add
"""
# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
        # Shell is non-interactive.  Be done now!
        return
fi
"""
to /etc/profile.d/modules.sh

#Configuration tasks
grid engine
NFS automount config and mounts
NIS autoconfig
Email config (ssmtp, logwatch, apcupsd)
photocopier printer
other printers
configure IPMI
local scratch directory
enable quarantine (mount + enable modules)
enable sudo for devgab
automatic smart disk checking
