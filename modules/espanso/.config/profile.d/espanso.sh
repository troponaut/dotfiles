#
# Setup espanso config
#

# - https://espanso.org/docs/
#

# shellcheck disable=SC1090


if [[ "$OSTYPE" == darwin* ]]; then
  if [ -d "$HOME/Library/Application Support/espanso" ]; then
    rmdir 0rf "$HOME/Library/Application Support/espanso"
  fi
fi
