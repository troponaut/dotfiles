#
# Setup espanso config
#

# - https://espanso.org/docs/
#

# shellcheck disable=SC1090

# Ensure espanso is installed
if ! command_exists "espanso"; then
  return 1
fi

# The config location
export ESPANSO_CONFIG_DIR="${XDG_CONFIG_HOME}/espanso"

# edit alias
alias espansoed="code $ESPANSO_CONFIG_DIR"