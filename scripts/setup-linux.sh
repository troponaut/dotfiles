#!/usr/bin/env bash

set -eo pipefail

# setup XDG environment variables
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

main() {
  local bin_dir="$DOTFILES_BIN"
  local mod_dir="$DOTFILES_MODULES_DIR"
  local default_modules=()

  # Core setup
  prepare_dirs() {
    mkdir -p "${XDG_CONFIG_HOME}"/less
    mkdir -p "${XDG_CACHE_HOME}"/less
    mkdir -p "${XDG_BIN_HOME}"
  }

  prepare_dirs

  # -----------------------------------------------------------------------------------------

  "$mod_dir/homebrew/install.sh" # Install Homebrew

  # Install packages with package manager
  "$bin_dir/pkg" install /
  stow

  # Ensure some directories exist
  mkdir -p "$HOME/.ssh"

  # Default modules
  default_modules=(
    _base
    1password
    bash
    bat
    duf
    fzf
    git
    github
    gpg
    homebrew
    local
    linux
    ripgrep
    ssh
    starship
    tmux
    utility
    zoxide
    zsh
  )

  # Ensure local modules directory exists
  mkdir -p "$DOTFILES_MODULES_DIR/local"

  # Create a modules file if it doesn't exist
  if [ ! -f "$DOTFILES_MODULES_FILE" ]; then
    cat <<EOF >"$DOTFILES_MODULES_FILE"
$(
      IFS=$'\n'
      echo "${default_modules[*]}"
    )
EOF
  fi

  # Link dotfiles
  "$bin_dir/dotfiles" modules link

  # Install 1password agents
  "$mod_dir/1password/install.sh"

}

main "$@"
