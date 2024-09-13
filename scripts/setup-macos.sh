#!/usr/bin/env bash

set -eo pipefail


  # Core setup
prepare_dirs() {
  mkdir -p "${XDG_CONFIG_HOME}"/less
  mkdir -p "${XDG_CACHE_HOME}"/less
  mkdir -p "${XDG_BIN_HOME}"
}

main() {
  local bin_dir="$DOTFILES_BIN"
  local mod_dir="$DOTFILES_MODULES_DIR"
  local default_modules=()

  prepare_dirs

  "$mod_dir/homebrew/install.sh"  # Install Homebrew
  "$mod_dir/1password/install.sh"  # Install 1password LaunchAgent

  # shellcheck source=/dev/null
  source "$mod_dir/homebrew/.config/homebrew/shellenv.sh"   # Load Homebrew shellenv

  # Install MacOS specific packages
  export HOMEBREW_BUNDLE_FILE="${mod_dir}/homebrew/.config/homebrew/Brewfile"
  brew bundle --no-lock

  # Ensure some directories exist
  mkdir -p "$HOME/.ssh"

  # Default modules
  default_modules=(
    _base
    1password
    bash
    bat
    docker
    eza
    fzf
    git
    github
    gpg
    homebrew
    kitty
    local
    macos
    #neovim
    nodejs
    python
    ripgrep
    rust
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
  # Install dotfiles module scripts - only Docker for now
  "$mod_dir/docker/install.sh"

  # Setup macos defaults
  "$DOTFILES_DIR/scripts/macos-defaults.sh"
}

main "$@"
