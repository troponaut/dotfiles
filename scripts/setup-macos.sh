#!/usr/bin/env bash

set -eo pipefail


  # Core setup
prepare_dirs() {
  mkdir -p "${XDG_CONFIG_HOME}"/less
  mkdir -p "${XDG_CACHE_HOME}"/less
  mkdir -p "${XDG_BIN_HOME}"
}


prompt_for_extra_brewfiles() {
  local env_vars=("dev" "macos" "vscode")
  for env_var in "${env_vars[@]}"; do
    read -p "Do you want to enable HOMEBREW_BUNDLE_INSTALL_${env_var^^}? (y/n): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      export "HOMEBREW_BUNDLE_INSTALL_${env_var^^}=1"
    else
      export "HOMEBREW_BUNDLE_INSTALL_${env_var^^}=0"
    fi
  done
}


main() {
  local bin_dir="$DOTFILES_BIN"
  local mod_dir="$DOTFILES_MODULES_DIR"
  local default_modules=()

  "$mod_dir/homebrew/install.sh"  # Install Homebrew

  # shellcheck source=/dev/null
  source "$mod_dir/homebrew/.config/homebrew/shellenv.sh"   # Load Homebrew shellenv

  # Prompt for extra Brewfiles
  prompt_for_extra_brewfiles

  # Install MacOS specific packages
  export HOMEBREW_BUNDLE_FILE="${mod_dir}/homebrew/.config/homebrew/Brewfile"


  brew bundle --no-lock

  # Ensure some directories exist
  mkdir -p "$HOME/.ssh"
  # prepare_dirs

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
    ruff
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

  # Install dotfiles module scripts
  "$mod_dir/1password/install.sh"  # Install 1password LaunchAgent
  "$mod_dir/docker/install.sh" # Install Docker
  
  # Setup macos defaults
  "$DOTFILES_DIR/scripts/macos-defaults.sh"
}

main "$@"
