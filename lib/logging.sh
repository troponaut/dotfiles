#!/usr/bin/env bash

RESET="$(tput sgr0)"
BOLD="$(tput bold)"

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
CYAN="$(tput setaf 6)"
GRAY="$(tput setaf 7)"

INFO="${BOLD}${BLUE}ℹ️ [INFO]${RESET}"
WARN="${BOLD}${YELLOW}⚠️ [WARN]${RESET}"

info() { printf "%b %s\n" "$INFO" "$*"; }
warn() { printf "%b %s\n" "$WARN" "$*"; }

debug() {
  # Prints message in bold red
  if [ -n "$DOTFILES_TRACE" ]; then
    printf '%s\n' "${BOLD}${RED}🔍 DEBUG: $*${RESET}"
  fi

}

info() {
  if [ -n "$DOTFILES_TRACE" ]; then
    # Prints message in gray with info emoji
    printf '%s\n' "${GRAY}ℹ️ INFO: $*${RESET}"
  fi
}
