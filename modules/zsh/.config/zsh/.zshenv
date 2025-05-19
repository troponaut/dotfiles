#!/usr/bin/env zsh
#
# Defines zsh environment & changes to use XGD directories
#

debug "loading ${(%):-%N}"
# shellcheck disable=SC2296
info "$(print_path)"

# The current shell type
export SHELL_TYPE="zsh"

# XDG configuration
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Ensure path arrays do not contain duplicates
typeset -gU cdpath fpath mailpath path

# Disable shell sessions
SHELL_SESSIONS_DISABLE=1

# Only source .zprofile if: TODO:
# - this is an interactive NON-login shell
if [[ -o interactive && ! -o login ]]; then
  source "${XDG_CONFIG_HOME}/zsh/.zprofile"
fi


# shellcheck source=../../../lib/init.sh
source "${DOTFILES_DIR}/lib/init.sh"
