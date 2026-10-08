# Keep the user caches off the NFS $HOME.
#
# pam_env sets XDG_CACHE_HOME and the other cache variables for every login
# type -- see files/pam_env_xdg_cache.conf. This script makes the directories,
# tests that an inherited directory is safe, and holds the parts that pam_env
# cannot do. It also works on a host where pam_env did not run.
#
# Sourced by /etc/profile and, through /etc/zsh/zprofile, by zsh. Keep it POSIX
# sh. Do not define a function here: the shell of the user keeps it.

_xdg_user="${USER:-$(id -un)}"

if [ -z "${XDG_CACHE_HOME}" ] ; then
  XDG_CACHE_HOME="/var/tmp/xdgcache-${_xdg_user}"
fi

# /var/tmp has mode 1777, so another user can make this directory first. Use it
# only if it is a directory, not a symbolic link, and we are the owner. If it
# fails these tests, make a private directory instead. `test -O` is not in the
# POSIX list, but bash, dash, zsh and busybox sh all have it.
_xdg_ok=yes
if [ -L "${XDG_CACHE_HOME}" ]; then
  _xdg_ok=no
elif [ -e "${XDG_CACHE_HOME}" ]; then
  if [ ! -d "${XDG_CACHE_HOME}" ] || [ ! -O "${XDG_CACHE_HOME}" ] || [ ! -w "${XDG_CACHE_HOME}" ]; then
    _xdg_ok=no
  fi
else
  (umask 077 && mkdir -p "${XDG_CACHE_HOME}") 2> /dev/null
  [ -d "${XDG_CACHE_HOME}" ] && [ -O "${XDG_CACHE_HOME}" ] || _xdg_ok=no
fi

if [ "${_xdg_ok}" = no ]; then
  _xdg_tmp="$(mktemp -d "${TMPDIR:-/var/tmp}/xdgcache-${_xdg_user}-XXXXXX" 2> /dev/null)"
  if [ -n "${_xdg_tmp}" ] && [ -d "${_xdg_tmp}" ]; then
    XDG_CACHE_HOME="${_xdg_tmp}"
  else
    # Nothing else is left. The home directory is slow, but it works.
    XDG_CACHE_HOME="${HOME}/.cache"
    (umask 077 && mkdir -p "${XDG_CACHE_HOME}") 2> /dev/null
  fi
  unset _xdg_tmp
fi
export XDG_CACHE_HOME

# The variables that pam_env also sets. Set them again, because the tests above
# can select a different XDG_CACHE_HOME, and because pam_env is not on a host
# that this play has not reached yet. The names come from the tools and from
# https://github.com/b3nj5m1n/xdg-ninja -- see files/pam_env_xdg_cache.conf.
export CONDA_PKGS_DIRS="${XDG_CACHE_HOME}/.condapkg"
export APPTAINER_CACHEDIR="${XDG_CACHE_HOME}/.apptainer"
export SINGULARITY_CACHEDIR="${XDG_CACHE_HOME}/.singularity"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
export YARN_CACHE_FOLDER="${XDG_CACHE_HOME}/yarn"
export GOMODCACHE="${XDG_CACHE_HOME}/go/mod"
export PYTHON_EGG_CACHE="${XDG_CACHE_HOME}/python-eggs"
export MCR_CACHE_ROOT="${XDG_CACHE_HOME}/mcr"
export CUDA_CACHE_PATH="${XDG_CACHE_HOME}/nv/ComputeCache"
export __GL_SHADER_DISK_CACHE_PATH="${XDG_CACHE_HOME}/nv/GLCache"
export TRITON_HOME="${XDG_CACHE_HOME}/triton"
export XCOMPOSECACHE="${XDG_CACHE_HOME}/X11/xcompose"
export TEXMFVAR="${XDG_CACHE_HOME}/texlive/texmf-var"
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# pip, uv, GOCACHE, ccache, huggingface, torch, matplotlib, mesa, fontconfig,
# the nvidia GL cache and the other XDG programs need no variable: they read
# XDG_CACHE_HOME.
(umask 077 && mkdir -p \
  "${CONDA_PKGS_DIRS}" \
  "${APPTAINER_CACHEDIR}" \
  "${SINGULARITY_CACHEDIR}" \
  "${NPM_CONFIG_CACHE}" \
  "${YARN_CACHE_FOLDER}" \
  "${GOMODCACHE}" \
  "${PYTHON_EGG_CACHE}" \
  "${MCR_CACHE_ROOT}" \
  "${CUDA_CACHE_PATH}" \
  "${__GL_SHADER_DISK_CACHE_PATH}" \
  "${TRITON_HOME}" \
  "${XCOMPOSECACHE}" \
  "${TEXMFVAR}" \
  "${STARSHIP_CACHE}" \
  "${XDG_CACHE_HOME}/.cache") 2> /dev/null

# Custom user flatpak dir, on the local disk. Not every host has /scratch.
if [ -d /scratch ]; then
  FLATPAK_USER_DIR="/scratch/${_xdg_user}/flatpak"
  export FLATPAK_USER_DIR
  mkdir -p "${FLATPAK_USER_DIR}" 2> /dev/null

  # Add the exports one time only. A login shell inside a login shell runs this
  # script again, and a value that ends with a colon makes the programs lose
  # the default /usr/local/share:/usr/share.
  case ":${XDG_DATA_DIRS}:" in
    *":${FLATPAK_USER_DIR}/exports/share:"*)
      ;;
    *)
      XDG_DATA_DIRS="${FLATPAK_USER_DIR}/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      export XDG_DATA_DIRS
      ;;
  esac
fi

unset _xdg_user _xdg_ok
