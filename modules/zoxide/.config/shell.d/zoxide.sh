#
# Initialize zoxide
#
# - https://github.com/ajeetdsouza/zoxide
#

# shellcheck disable=SC1090

# Ensure zoxide is installed
if ! command_exists "zoxide"; then
  return 1
fi

# The data location
export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"

# When set to 1, z will print the matched directory before navigating to it.
export _ZO_ECHO=0

# Initialize xodize for bash
if [ -n "${BASH_VERSION}" ]; then
  eval "$(zoxide init bash)"

# Initialize xodize for zsh
elif [ -n "${ZSH_VERSION}" ]; then
  eval "$(zoxide init zsh --cmd cd)"

# Fallback to posix initialize
else
  eval "$(zoxide init posix --hook prompt)"
fi
