#!/usr/bin/env zsh
#
# Executes commands at the start of an interactive session
#

# Enable zprof performance profiling
[ -n "$PROFILE_STARTUP" ] && zmodload zsh/zprof

# Source zsh core scripts
source_files_in "${XDG_CONFIG_HOME}"/zsh/init.d/*.zsh

# Source zsh plugins
source_files_in "${XDG_CONFIG_HOME}"/zsh/plugins/*.zsh

# Append bin directories to path
prepend_path "${DOTFILES_DIR}/bin"
prepend_path "${HOME}/.local/bin"
