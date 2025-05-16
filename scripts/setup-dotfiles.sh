#!/usr/bin/env bash

# Summary:
#   Install & setup the dotfiles.
#

set -eo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
export DOTFILES_BIN="$DOTFILES_DIR/bin"
export DOTFILES_DISABLE_SUDO="${DOTFILES_DISABLE_SUDO:-0}"

backup_dotfiles() {
  # Rename existing dotfiles
  local files=(~/.bash_profile ~/.bashrc ~/.zshenv ~/.zshrc)

  # move existing files
  for file in "${files[@]}"; do
    if [ -f "${file}" ] && [ ! -L "${file}" ]; then
      mv "${file}" "${file}.bak"
    fi
  done
}

main() {

  source "${DOTFILES_DIR}"/lib/init.sh

  # Backup existing dotfiles
  backup_dotfiles

  # Run OS specific setup script
  case "$("$DOTFILES_BIN"/os-info --family)" in
  "macos") "$DOTFILES_DIR/scripts/setup-macos.sh" ;;
  "debian") "$DOTFILES_DIR/scripts/setup-linux.sh" ;;
  "fedora") "$DOTFILES_DIR/scripts/setup-linux.sh" ;;
  *) echo "Unsupported OS family: $OS_FAMILY" ;;
  esac
}

main "$@"
