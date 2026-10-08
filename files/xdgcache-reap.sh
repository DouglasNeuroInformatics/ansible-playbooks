#!/bin/sh
# Remove the local cache directory of a user who does not use this host.
#
# Nothing cleans /var/tmp -- see files/xdgcache-exclude.conf -- so
# /var/tmp/xdgcache-* grows with no limit. /var/tmp shares the root filesystem
# with /scratch on each host, and the directory of a user who left stays for
# years. cichm01 had 23 directories, some from April 2025.
#
# This script removes a full directory. It never removes single files from
# inside one, because that makes a cache bad instead of empty.
#
# Usage: xdgcache-reap [--dry-run] [age-in-days]
#
# Installed by roles/common/tasks/xdg-cache.yml, started each week by
# xdgcache-reap.timer.

set -u

dry_run=no
age_days=30

for arg in "$@"; do
  case "${arg}" in
    --dry-run) dry_run=yes ;;
    [0-9]*) age_days="${arg}" ;;
    *) echo "usage: $0 [--dry-run] [age-in-days]" >&2; exit 2 ;;
  esac
done

# The age test compares against a stamp file, because -newer is in POSIX and
# -newermt is not. A failure removes the stamp and stops the run.
stamp="$(mktemp)" || exit 1
trap 'rm -f "${stamp}"' EXIT
trap 'rm -f "${stamp}"; exit 1' HUP INT TERM
touch -d "${age_days} days ago" "${stamp}" || exit 1

for dir in /var/tmp/xdgcache-*; do
  # The glob itself, when no directory has this name.
  [ -e "${dir}" ] || continue

  # Never follow a link, and take a directory only.
  [ -L "${dir}" ] && continue
  [ -d "${dir}" ] || continue

  # Care before an rm as root: the path must have the prefix that xdg.cache.sh
  # and its mktemp fallback use. The owner, the session and the age below are
  # the other guards.
  case "${dir}" in
    /var/tmp/xdgcache-*) ;;
    *) continue ;;
  esac

  # Read the owner from the directory, not from the name: the name of a mktemp
  # fallback directory has a random end, and an empty USER made
  # /var/tmp/xdgcache- on some hosts.
  owner_uid="$(stat -c %u "${dir}" 2>/dev/null)" || continue
  owner_name="$(stat -c %U "${dir}" 2>/dev/null)" || continue

  # Keep the system accounts. The cache of a service is small, and a service
  # can use one without a session that loginctl knows.
  [ "${owner_uid}" -ge 1000 ] 2>/dev/null || continue

  # Keep the cache of a user with a session on this host, and of a user whose
  # systemd manager still runs.
  loginctl show-user "${owner_uid}" > /dev/null 2>&1 && continue

  # Keep the cache of a user with a process on this host. A slurm job step has
  # no logind session -- the compute nodes have PrologFlags=Contain and no
  # UsePAM -- and a job can read MCR_CACHE_ROOT or TRITON_HOME for its full
  # run. A tmux session after a logout and a cron job have no session either.
  pgrep -u "${owner_uid}" > /dev/null 2>&1 && continue

  # Keep the directory if anything in it is newer than the stamp. -quit stops
  # the walk at the first file that is new enough. A find that fails keeps the
  # directory: this test must never fail to the side of rm.
  newer="$(find "${dir}" -newer "${stamp}" -print -quit 2>/dev/null)" || continue
  [ -n "${newer}" ] && continue

  if [ "${dry_run}" = yes ]; then
    echo "would remove ${dir} (${owner_name}, nothing newer than ${age_days} days)"
    continue
  fi

  echo "removing ${dir} (${owner_name}, nothing newer than ${age_days} days)"
  # go makes the files in its module cache read-only, so rm alone cannot do it.
  # chmod -R does not follow a link that it finds on the way.
  chmod -R u+w "${dir}" 2> /dev/null
  rm -rf "${dir}"
done
