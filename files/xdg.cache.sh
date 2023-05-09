# could be more paranoid, and not accept any previously defined XDG_CACHE_HOME
if [ -z "${XDG_CACHE_HOME}" ] ; then
  XDG_CACHE_HOME="/var/tmp/xdgcache-${USER}"
  export XDG_CACHE_HOME
fi

if [ -d "${XDG_CACHE_HOME}" ]; then
  # verify existing dir is suitable
  if ! `test -G "${XDG_CACHE_HOME}" -a -w "${XDG_CACHE_HOME}"` ; then
    # else, make a new/secure one with mktemp
    XDG_CACHE_HOME="$(mktemp -d ${XDG_CACHE_HOME}-XXXXXX)"
    export XDG_CACHE_HOME
  fi
else
  mkdir -p "${XDG_CACHE_HOME}"
fi

export FLATPAK_USER_DIR="/scratch/${USER}/flatpak"
mkdir -p ${FLATPAK_USER_DIR}
