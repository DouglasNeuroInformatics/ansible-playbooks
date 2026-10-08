#!/bin/sh
# Remove the cache directory of a user who no longer uses this host.
#
# No job cleans /var/tmp (see files/xdgcache-exclude.conf), so the
# /var/tmp/xdgcache-* directories grow without limit. On these hosts, /var/tmp
# and /scratch are on the root file system. The directory of a user who left
# stays until something removes it.
#
# This script removes full directories only. It never removes single files from
# a directory, because that makes the cache corrupt.
#
# Usage: xdgcache-reap [--dry-run] [AGE_IN_DAYS]
#   --dry-run    show the directories that a run would remove, and remove none
#   AGE_IN_DAYS  keep a directory that has a file newer than this (default 30)
#
# roles/common/tasks/xdg-cache.yml installs this script, and xdgcache-reap.timer
# starts it each week.

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

# Compare file times with a stamp file: `find -newer` is in POSIX, and
# `-newermt` is not. If the stamp file cannot be made, stop and remove nothing.
stamp="$(mktemp)" || exit 1
trap 'rm -f "${stamp}"' EXIT
trap 'rm -f "${stamp}"; exit 1' HUP INT TERM
touch -d "${age_days} days ago" "${stamp}" || exit 1

for dir in /var/tmp/xdgcache-*; do
  # If no directory matches, the loop gets the pattern itself.
  [ -e "${dir}" ] || continue

  # Do not follow symbolic links. Accept directories only.
  [ -L "${dir}" ] && continue
  [ -d "${dir}" ] || continue

  # Safety check before rm -rf as root: the path must start with the prefix
  # that xdg.cache.sh and its mktemp fallback use. The owner, session, process
  # and age checks below give more protection.
  case "${dir}" in
    /var/tmp/xdgcache-*) ;;
    *) continue ;;
  esac

  # Get the owner from the directory, not from its name. A mktemp fallback name
  # ends with random characters, and the old empty-USER bug made
  # /var/tmp/xdgcache- with no user name.
  owner_uid="$(stat -c %u "${dir}" 2>/dev/null)" || continue
  owner_name="$(stat -c %U "${dir}" 2>/dev/null)" || continue

  # Keep the directories of system accounts (UID below 1000). These caches are
  # small, and a service can use its cache without a logind session.
  [ "${owner_uid}" -ge 1000 ] 2>/dev/null || continue

  # Keep the cache if the user has a session on this host, or a systemd user
  # manager that still runs.
  loginctl show-user "${owner_uid}" > /dev/null 2>&1 && continue

  # Keep the cache if the user has a process on this host. Some processes have
  # no logind session: a slurm job step (the compute nodes use
  # PrologFlags=Contain and no UsePAM), a tmux session after logout, and a cron
  # job. A job can read MCR_CACHE_ROOT or TRITON_HOME while it runs.
  pgrep -u "${owner_uid}" > /dev/null 2>&1 && continue

  # Keep the directory if it contains a file newer than the stamp. -quit stops
  # at the first match. If find fails, keep the directory: an error must never
  # cause a removal.
  newer="$(find "${dir}" -newer "${stamp}" -print -quit 2>/dev/null)" || continue
  [ -n "${newer}" ] && continue

  if [ "${dry_run}" = yes ]; then
    echo "would remove ${dir} (${owner_name}, nothing newer than ${age_days} days)"
    continue
  fi

  echo "removing ${dir} (${owner_name}, nothing newer than ${age_days} days)"
  # go makes its module cache read-only, and rm cannot remove it without write
  # permission. chmod -R does not follow symbolic links.
  chmod -R u+w "${dir}" 2> /dev/null
  rm -rf "${dir}"
done
