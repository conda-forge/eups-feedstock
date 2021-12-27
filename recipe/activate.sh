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
export CONDA_EUPS_BACKUP_setup="`declare -f setup`"
unset -f setup 2>/dev/null || true
if [ -z "$CONDA_EUPS_BACKUP_setup" ]; then
  unset CONDA_EUPS_BACKUP_setup
fi
export CONDA_EUPS_BACKUP_unsetup="`declare -f unsetup`"
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
. "${EUPS_DIR}/bin/setups.sh"
if [ -n "${BASH}" ]; then
  export -f setup
  export -f unsetup
fi

