#!/usr/bin/env bash
#
# Common aliases
#

# Go to the dotfiles directory
if [ -n "${DOTFILES_DIR}" ]; then
  alias dotdir='cd ${DOTFILES_DIR}'
  alias dotedit='code ${DOTFILES_DIR}'
fi
