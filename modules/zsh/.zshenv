#!/usr/bin/env zsh
#
# Bootstrap ~/.zshenv file to xdg config
#

# Dotfiles initialization
export DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"

# Logging
# export DOTFILES_TRACE="1"
source "${DOTFILES_DIR}/lib/logging.sh"
source "${DOTFILES_DIR}/lib/utils.sh"

debug "loading ${(%):-%N}"
# shellcheck disable=SC2296
info "$(print_path)"

# XDG configuration
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Zsh home directory
ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# Load the zshenv
source "${ZDOTDIR}/.zshenv"
