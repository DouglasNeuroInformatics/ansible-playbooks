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

# Custom user flatpak dir
export FLATPAK_USER_DIR="/scratch/${USER}/flatpak"
mkdir -p ${FLATPAK_USER_DIR}

export XDG_DATA_DIRS=${FLATPAK_USER_DIR}/exports/share:${XDG_DATA_DIRS}

# Conda Caching
export CONDA_PKGS_DIRS=${XDG_CACHE_HOME}/.condapkg
mkdir -p  ${CONDA_PKGS_DIRS}

# Singularity and apptainer
export APPTAINER_CACHEDIR=${XDG_CACHE_HOME}/.apptainer
export SINGULARITY_CACHEDIR=${XDG_CACHE_HOME}/.singularity
mkdir -p ${APPTAINER_CACHEDIR} ${SINGULARITY_CACHEDIR}

# $HOME/.cache
mkdir -p ${XDG_CACHE_HOME}/.cache
export HOME_CACHEDIR=${XDG_CACHE_HOME}/.cache
#if the old $HOME/.cache directory exists and isn't a symlink, then redirect it
if [ -e $HOME/.cache ] && [ ! -L $HOME/.cache ]
  then
     mv $HOME/.cache $HOME/.cache.old
     ln -s ${XDG_CACHE_HOME}/.cache $HOME/.cache
fi
