#!/usr/bin/env bash
#
# Setup homebrew
#

set -e

install_homebrew() {
  echo "Checking if homebrew is installed..."

  # Load homebrew shellenv to see if it's installed
  # shellenv will make brew available in the current shell
  # shellcheck disable=SC1091

  source "$DOTFILES_MODULES_DIR"/homebrew/.config/homebrew/shellenv.sh

  # If shellenv.sh made brew available, then Homebrew is installed.
  if [ -x "$(command -v brew)" ]; then
    echo "Homebrew is already installed."
    return
  fi

  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Re-load Homebrew’s env into *this* shell
  source "$DOTFILES_MODULES_DIR"/homebrew/.config/homebrew/shellenv.sh
}

install_brews() {
  # Install brews using brew bundle (uses the Brewfile) TODO: but has shallenv.sh sourced yet?
  if [ -x "$(command -v brew)" ]; then
    printf "Do you want run brew bundle [y/N]? "
    read -r answer
    case "${answer}" in [yY] | [yY][eE][sS])
      brewfile="${DOTFILES_MODULES_DIR}/homebrew/.config/homebrew/Brewfile"
      HOMEBREW_BUNDLE_FILE="$brewfile" brew bundle
      ;;
    esac
  fi
}

main() {
  case "$("$DOTFILES_BIN"/os-info --family)" in
  "macos")
    install_homebrew
    install_brews
    ;;
  *) ;;
  esac
}

main "$@"
