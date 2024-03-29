#
# Initialize 1password cli environment
#

if ! command_exists "op"; then
  return 1
fi

# Symlink agent.sock for convenient access
ln -sf "${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "${XDG_CONFIG_HOME}/op/agent.sock"

# Initial plugins
if [ -f "${XDG_CONFIG_HOME}/op/plugins.sh" ]; then
  # shellcheck source=./plugins.sh disable=SC1091
  source "${XDG_CONFIG_HOME}/op/plugins.sh"
fi

# Aliases
alias opr="op run --"

#
# helper functions
#

use-1password-ssh-agent() {
  if [ -L "${XDG_CONFIG_HOME}/op/agent.sock" ]; then
    export SSH_AUTH_SOCK="${XDG_CONFIG_HOME}/op/agent.sock"
  else
    echo "1password ssh agent not found"
    return 1
  fi
}

# Load 1Password environment variables
if command_exists "direnv"; then
  ope() {
    export DIRENV_LOAD_OP_ENV=1
    direnv reload
  }
fi
