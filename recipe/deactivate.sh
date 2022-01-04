# shellcheck shell=sh
# Deactivate EUPS
# 
# Derived from the stackvana-core recipe by Matt Becker (GitHub @beckermr)
# see: https://github.com/beckermr/stackvana-core/blob/master/recipe/stackvana_deactivate.sh
#

get_setup () {
    eups list -s --raw 2>/dev/null \
	| grep -v '^eups|' | head -1 | cut -d'|' -f1 \
	|| echo ""
}

# unsetup any products to keep env clean
__eups_pkg=$(get_setup)
while [ -n "$__eups_pkg" ]; do
    unsetup "$__eups_pkg" > /dev/null 2>&1
    __eups_pkg=$(get_setup)
done
unset __eups_pkg


# clean out the path, removing EUPS_DIR/bin
# https://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
# we are not using the function below because this seems to mess with conda's
# own path manipulations
WORK=":$PATH:"
REMOVE=":${EUPS_DIR}/bin:"
WORK="${WORK//$REMOVE/:}"
WORK="${WORK%:}"
WORK="${WORK#:}"
export PATH="$WORK"
unset WORK
unset REMOVE


# restore EUPS env variables existing prior to the activation
for __eups_var in EUPS_PATH EUPS_SHELL SETUP_EUPS EUPS_DIR; do
  unset $__eups_var
  __eups_bkvar="CONDA_EUPS_BACKUP_$__eups_var"
  eval "__eups_value=\"\${$__eups_bkvar}\""
  if [ -n "${__eups_value}" ]; then
    export $__eups_var="${__eups_value}"
    unset "$__eups_bkvar"
  fi
done
unset __eups_bkvar
unset __eups_var
unset -f setup
if [ "$CONDA_EUPS_BACKUP_setup" ]; then
  eval "$CONDA_EUPS_BACKUP_setup"
  unset CONDA_EUPS_BACKUP_setup
fi
unset -f unsetup
if [ "$CONDA_EUPS_BACKUP_unsetup" ]; then
  eval "$CONDA_EUPS_BACKUP_unsetup"
  unset CONDA_EUPS_BACKUP_unsetup
fi


# restoring exisisting python path
if [ "${CONDA_EUPS_BACKUP_PYTHONPATH}" ]; then
  export PYTHONPATH="${CONDA_EUPS_BACKUP_PYTHONPATH}"
  unset CONDA_EUPS_BACKUP_PYTHONPATH
else
  unset PYTHONPATH
fi

