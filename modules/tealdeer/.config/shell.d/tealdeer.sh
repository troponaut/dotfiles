#
# Initialize tealdeer
#
# - https://github.com/dbrgn/tealdeer
#

# shellcheck disable=SC1090

# Ensure tealdeer is installed
if ! command_exists "tldr"; then
  return 1
fi

# The config location
export TEALDEER_CONFIG_DIR="${XDG_CONFIG_HOME}/tealdeer"

# XDG_DATA_HOME := $(HOME)/.local/share
# XDG_CACHE_HOME := $(HOME)/.cache