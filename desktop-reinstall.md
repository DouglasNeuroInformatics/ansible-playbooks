#download debs
http://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-14_amd64.deb
https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
https://github.com/jgm/pandoc/releases/download/1.13.2/pandoc-1.13.2-1-amd64.deb
https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb

#PPA
deb http://downloads.hipchat.com/linux/apt stable main
wget -O - https://www.hipchat.com/keys/hipchat-linux.key | apt-key add -

ppa:inkscape.dev/stable
ppa:ansible/ansible
ppa:libreoffice/ppa
ppa:nilarimogard/webupd8 
ppa:webupd8team/java
ppa:x2go/stable
ppa:otto-kesselgulasch/gimp

ppa:blahota/texstudio
ppa:videolan/stable-daily
ppa:webupd8team/atom
ppa:ubuntu-x-swat/x-updates
ppa:zfs-native/stable

ppa:tsvetko.tsvetkov/cinnamon

deb http://archive.canonical.com/ precise partner #for acroread

#desktop packages
classicmenu-indicator
unity-tweak-tool
x2goserver
x2goclient
hipchat
skype
speedcrunch
inkscape
gimp
gimp-plugin-registry
synaptic
spyder
texlive-full
texstudio
mupdf
vlc
vlc-plugin-notify
imagej
gparted
mricron
freshplayerplugin
cinnamon
pidgin
atom
gedit-plugins
xfig
gimp-help-en
icc-profiles-free
cuda
vdpau-driver
acroread-bin
libldap-2.4-2:i386
libgnome-speech7:i386
librsvg2-common:i386
gvfs:i386
libjasper-runtime:i386
ttf-baekmuk
libcanberra-gtk-module:i386
gtk2-engines-murrine:i386
gsmartcontrol
smart-notifier
gimp-help-en-gb
hunspell-en-ca
libreoffice-help-en-gb
libreoffice-l10n-en-gb
libreoffice-l10n-en-za
mythes-en-au
thunderbird-locale-en-gb
firefox-locale-fr
gimp-help-fr
hunspell-fr
hyphen-fr
language-pack-fr
language-pack-gnome-fr
libreoffice-help-fr
libreoffice-l10n-fr
mythes-fr
thunderbird-locale-fr
wfrench
language-pack-fr
gnuplot-qt
xauth
xterm
qemu-kvm
libvirt-bin
virtinst
virt-viewer
numlockx

#packages
thermald
tmux
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
oracle-java8-installer
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
NFS automount config and mounts
NIS autoconfig
Email config (ssmtp, logwatch, apcupsd)
lightdm config (power key, login screen)
chrome adblock
firefox adblock
hosts file
photocopier printer
other printers
configure IPMI
local scratch directory
enable quarantine (mount + enable modules)
configure xorg-edgers
disable apport
enable sudo for devgab


