# Keep the user caches off the NFS home directories.
#
# pam_env sets XDG_CACHE_HOME and the other cache variables for every type of
# login: see files/pam_env_xdg_cache.conf. In a login shell, this script also:
#   - examines the cache directory, and replaces it if it is not safe,
#   - makes the cache directory of each tool,
#   - sets the flatpak path.
# The script also works on a host where pam_env does not set the variables.
#
# /etc/profile sources this file, and zsh sources it through /etc/zsh/zprofile.
# Use POSIX sh only. Do not define functions: they stay in the shell of the
# user.

_xdg_user="${USER:-$(id -un)}"

if [ -z "${XDG_CACHE_HOME}" ] ; then
  XDG_CACHE_HOME="/var/tmp/xdgcache-${_xdg_user}"
fi

# /var/tmp has mode 1777, so another user can make this directory first. Use
# the directory only if it is a real directory (not a symbolic link) and the
# user owns it. Otherwise, make a private directory with mktemp.
# `test -O` is not in POSIX, but bash, dash, zsh and busybox sh support it.
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
    # Last fallback: the home directory is slow, but it works.
    XDG_CACHE_HOME="${HOME}/.cache"
    (umask 077 && mkdir -p "${XDG_CACHE_HOME}") 2> /dev/null
  fi
  unset _xdg_tmp
fi
export XDG_CACHE_HOME

# pam_env also sets these variables. Set them again here for two reasons: the
# checks above can change XDG_CACHE_HOME, and pam_env does not set them on a
# host that has not received this change yet. For the source of the names, see
# files/pam_env_xdg_cache.conf.
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
export CUPY_CACHE_DIR="${XDG_CACHE_HOME}/cupy"
export XCOMPOSECACHE="${XDG_CACHE_HOME}/X11/xcompose"
export TEXMFVAR="${XDG_CACHE_HOME}/texlive/texmf-var"
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# Tools that read XDG_CACHE_HOME need no variable: pip, uv, GOCACHE, ccache,
# huggingface, torch, matplotlib, mesa, fontconfig, the nvidia GL cache and
# others.
#
# $XDG_CACHE_HOME/.cache comes from commit cfa65e0. No file in this repository
# uses it.
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
  "${CUPY_CACHE_DIR}" \
  "${XCOMPOSECACHE}" \
  "${TEXMFVAR}" \
  "${STARSHIP_CACHE}" \
  "${XDG_CACHE_HOME}/.cache") 2> /dev/null

# Put the user flatpak installation on the local disk. Some hosts do not have
# /scratch.
if [ -d /scratch ]; then
  FLATPAK_USER_DIR="/scratch/${_xdg_user}/flatpak"
  export FLATPAK_USER_DIR
  mkdir -p "${FLATPAK_USER_DIR}" 2> /dev/null

  # Add the flatpak exports only once, because a nested login shell runs this
  # script again. If XDG_DATA_DIRS is empty, also add the default
  # /usr/local/share:/usr/share. A value that ends with a colon drops it.
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
