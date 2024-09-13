#!/usr/bin/env bash
# Summary:
#   Install & setup this dotfiles repo
#
# Usage:
#   ./install.sh
#
# Environmenet Variables:
#   DOTFILES_DIR                        The target directory for the dotfiles repo
#   DOTFILES_DISABLE_SUDO               Allow usage of sudo: 1 (no) or 0 (yes)
#   DOTFILES_LOGGING                    Enable logging: 1 (yes) or 0 (no)
#
# Examples:
#   ./install.sh
#   DOTFILES_DIR="$HOME/my-dotfiles" ./install.sh
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/troponaut/dotfiles/main/install.sh)"

set -eo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
export DOTFILES_BIN="$DOTFILES_DIR/bin"
export DOTFILES_DISABLE_SUDO="${DOTFILES_DISABLE_SUDO:-0}"
export DOTFILES_LOGGING="${DOTFILES_LOGGING:-1}"

# Source the logging script
source "$DOTFILES_DIR/lib/logging.sh"

clone_dotfiles() {
  
  if [ ! -d "${DOTFILES_DIR}" ]; then
    echo_log "Cloning dotfiles repo..."
    git clone "https://github.com/troponaut/dotfiles.git" "$DOTFILES_DIR"

    # Ensure repo is using the ssh remote
    # pushd "${DOTFILES_DIR}" >/dev/null
    # git remote set-url origin git@github.com:troponaut/dotfiles.git
    # popd >/dev/null
  fi
}

# shellcheck disable=SC2317
backup_dotfiles() {
  echo_log "Backing up existing dotfiles"
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
  if [ "$DOTFILES_LOGGING" -eq 1 ]; then
    echo_log "DOTFILES_LOGGING: $DOTFILES_LOGGING"
    echo_log "DOTFILES_DIR: $DOTFILES_DIR"
    echo_log "DOTFILES_DISABLE_SUDO: $DOTFILES_DISABLE_SUDO"
  fi
  

  # Clone and initialize dotfiles env
  clone_dotfiles
  source "${DOTFILES_DIR}"/lib/init.sh

  # Backup existing dotfiles
  backup_dotfiles

  # Run OS specific setup script
  case "$("$DOTFILES_BIN"/os-info --family)" in
    "macos") "$DOTFILES_DIR/scripts/setup-macos.sh" ;;
  esac
}

main "$@"