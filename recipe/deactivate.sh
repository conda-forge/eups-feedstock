# shellcheck shell=sh
# Deactivate EUPS
# 
# Derived from the stackvana-core recipe by Matt Becker (GitHub @beckermr)
# see: https://github.com/beckermr/stackvana-core/blob/master/recipe/stackvana_deactivate.sh
#

# If we're executing in a subshell that doesn't know about unsetup, we can't
# affect the real environment, so don't even try to do anything.
# (The environment should be fixed up later by a proper reactivate.)
command -v unsetup > /dev/null 2>&1 || return 0

__eups_get_setup () {
    eups list -s --raw 2>/dev/null \
	| grep -v '^eups|' | head -1 | cut -d'|' -f1 \
	|| echo ""
}

# unsetup any products to keep env clean
__eups_pkg=$(__eups_get_setup)
while [ -n "$__eups_pkg" ]; do
    unsetup "$__eups_pkg" > /dev/null 2>&1
    __eups_pkg=$(__eups_get_setup)
done
unset __eups_pkg
unset -f __eups_get_setup

# clean out the path, removing EUPS_DIR/bin
# https://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
# but use sed instead of bash-only regexp parameter substitution
__EUPS_WORK=":$PATH:"
# : is a safe regexp delimiter
__EUPS_WORK=$(echo "$__EUPS_WORK" | sed -e "s:\:${EUPS_DIR}/bin\::\::")
__EUPS_WORK="${__EUPS_WORK%:}"
__EUPS_WORK="${__EUPS_WORK#:}"
export PATH="$__EUPS_WORK"
unset __EUPS_WORK


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
  __setup_restored=1
fi
unset -f unsetup
if [ "$CONDA_EUPS_BACKUP_unsetup" ]; then
  eval "$CONDA_EUPS_BACKUP_unsetup"
  unset CONDA_EUPS_BACKUP_unsetup
  __setup_restored=1
fi
if [ -n "$EUPS_DIR" ] && [ -z $__setup_restored ]; then
  # shellcheck disable=SC1091
  . "${EUPS_DIR}/bin/setups.sh"
fi
unset __setup_restored


# restoring exisisting python path
if [ "${CONDA_EUPS_BACKUP_PYTHONPATH}" ]; then
  export PYTHONPATH="${CONDA_EUPS_BACKUP_PYTHONPATH}"
  unset CONDA_EUPS_BACKUP_PYTHONPATH
else
  unset PYTHONPATH
fi

