# shellcheck shell=sh
# Bootstrap EUPS
#
# Derived from the stackvana-core recipe by Matt Becker (GitHub @beckermr)
# see: https://github.com/beckermr/stackvana-core/blob/master/recipe/stackvana_activate.sh
#


# clean/backup existing EUPS environment variable
for var in EUPS_PATH EUPS_SHELL SETUP_EUPS EUPS_DIR; do
  eval "value=\"\${$var}\""
  if [ -n "${value}" ]; then
    export CONDA_EUPS_BACKUP_${var}="${value}"
  fi
  unset $var
done
# shellcheck disable=SC2155,SC3044
export CONDA_EUPS_BACKUP_setup="$(declare -f setup 2>/dev/null)"
unset -f setup 2>/dev/null || true
if [ -z "$CONDA_EUPS_BACKUP_setup" ]; then
  unset CONDA_EUPS_BACKUP_setup
fi
# shellcheck disable=SC2155,SC3044
export CONDA_EUPS_BACKUP_unsetup="$(declare -f unsetup 2>/dev/null)"
unset -f unsetup 2>/dev/null || true
if [ -z "$CONDA_EUPS_BACKUP_unsetup" ]; then
  unset CONDA_EUPS_BACKUP_unsetup
fi


# backup the python path in case eups is changing it
if [ -n "${PYTHONPATH}" ]; then
  export CONDA_EUPS_BACKUP_PYTHONPATH="${PYTHONPATH}"
fi


# initializing eups
EUPS_DIR="${CONDA_PREFIX}/eups"
# shellcheck disable=SC1091
. "${EUPS_DIR}/bin/setups.sh"
if [ -n "${BASH}" ]; then
  # shellcheck disable=SC3045
  export -f setup
  # shellcheck disable=SC3045
  export -f unsetup
fi

