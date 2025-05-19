#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# bootstrap.sh — Interactive dotfiles & environment bootstrapper for macOS/Linux
# -----------------------------------------------------------------------------
# Purpose   : Clone a dotfiles repo into $HOME/.dotfiles and kick‑off its
#             install script, then (optionally) let the user switch login shells.
# Audience  : Fresh installations of macOS or any modern Linux distribution.
# Author    : George V — May 2025
# License   : MIT
# -----------------------------------------------------------------------------

# ========================  Safety & Reliability Guards  =======================
# ‑e   : exit immediately if a command fails
# ‑u   : treat unset variables as errors
# ‑o pipefail : the exit code of a pipeline is the first failing command
# ‑E   : inherit ERR traps in shell functions & subshells
set -Eeuo pipefail

# Catch unhandled errors and print a helpful message           ────────────────
trap 'printf "\033[31m[ERROR]\033[0m line %d: command failed; aborting.\n" "$LINENO" >&2' ERR

# =========  Pretty printing helpers (colourised, cross‑platform)  ============
# ANSI colour escapes are POSIX‑portable on Apple Terminal, iTerm2, GNOME‑Term…
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
DEBUG="${BOLD}${RED}🔍 [DEBUG]${RESET}"

info() { printf "%b %s\n" "$INFO" "$*"; }
warn() { printf "%b %s\n" "$WARN" "$*"; }
debug() { printf "%b %s\n" "$DEBUG" "$*"; }

# Yes/No prompt that returns 0 on yes, 1 on no                  ────────────────
confirm() {
  local prompt=${1:-"Continue?"} reply
  read -rp "${prompt} [Y/n] " reply
  # only explicit “y” or “yes” returns true; empty or anything else is “no”
  [[ -z $reply || $reply =~ ^([yY][eE][sS]|[yY])$ ]]
}

# ===========================  Configuration  ================================

REPO_URL="https://github.com/troponaut/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# ========================  System‑information banner  ========================
USER_NAME="$(id -un)"
GROUP_NAME="$(id -gn)"
USER_ID="$(id -u)"
GROUP_ID="$(id -g)"
HOSTNAME="$(hostname)"
OS_KERNEL="$(uname -s)"
ARCH="$(uname -m)"
SHELL="$(basename "$SHELL")"

if [[ $OS_KERNEL == "Darwin" ]]; then
  OS_PRETTY="macOS $(sw_vers -productVersion)"
elif [[ -f /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release && OS_PRETTY="${PRETTY_NAME:-$NAME $VERSION}"
else
  OS_PRETTY="$OS_KERNEL"
fi

clear
cat <<EOF
${BOLD}Welcome, $USER_NAME! 👋  Let's make you feel like home.${RESET}

${BOLD}Detected system:${RESET}
  Hostname : $HOSTNAME
  OS       : $OS_PRETTY
  Arch     : $ARCH
  User     : ${BOLD}$USER_NAME${RESET}($USER_ID) -- ${RESET}($GROUP_ID)
  Shell    : $SHELL

EOF

info "This script will clone your dotfiles repository"
info "🌐 ${CYAN}$REPO_URL${RESET}"
info "💾 ${CYAN}$DOTFILES_DIR${RESET}"

confirm "Does this look correct?" || {
  info "Let's update the configuration."
  read -rp "Enter the repo URL [${YELLOW}$REPO_URL${RESET}]: " REPO_URL_INPUT
  REPO_URL="${REPO_URL_INPUT:-$REPO_URL}"
  read -rp "Enter destination [${YELLOW}$DOTFILES_DIR${RESET}]: " DOTFILES_DIR_INPUT
  DOTFILES_DIR_INPUT="${DOTFILES_DIR_INPUT:-$DOTFILES_DIR}"
  DOTFILES_DIR="${DOTFILES_DIR_INPUT/#\~/$HOME}"
  info "Using repository: ${GREEN}$REPO_URL${RESET}"
  info "Using directory: ${GREEN}$DOTFILES_DIR${RESET}"
  confirm "All good now?" || {
    info "Exiting."
    exit 0
  }
}

export DOTFILES_DIR # Ensure it's always exported for child processes

# ======================  Clone dotfiles repository  ==========================
if [[ -d $DOTFILES_DIR ]]; then
  warn "$DOTFILES_DIR already exists."
  warn "${RED}${BOLD} Existing files will be overwritten.${RESET}"
  if confirm "Skip cloning?"; then
    info "Skipping clone; keeping existing directory."
  else
    info "Removing old directory…"
    rm -rf "$DOTFILES_DIR"
    info "Cloning repository (shallow, depth=1)…"
    git clone --depth=1 --recursive "$REPO_URL" "$DOTFILES_DIR"
  fi
else
  info "Cloning repository (shallow, depth=1)…"
  # --depth=1  fetch the most recent snapshot only (faster, smaller)
  # --recursive ensures submodules (if any) are pulled on first go
  git clone --depth=1 --recursive "$REPO_URL" "$DOTFILES_DIR"
fi

# ======================  Run dotfiles install script  ========================
info "Running dotfiles installer…"
# Use bash explicitly in case ./install.sh lacks an exec bit or shebang
bash "$DOTFILES_DIR/scripts/setup-dotfiles.sh" || {
  warn "Installer script failed. Please check the output."
  info "Exiting."
  exit 1
}

# ===================  Offer to switch the default shell  =====================
CURRENT_SHELL="$(basename "$SHELL")"
cat <<EOF

${BOLD}Current login shell:${RESET} $CURRENT_SHELL
You may keep it, or switch to another.
EOF

if confirm "Would you like to keep your shell?"; then
  info "Keeping existing shell."
else
  PS3="Select a shell by number (or Ctrl‑C to cancel): "
  select choice in bash zsh "Cancel"; do
    case $choice in
    bash | zsh)
      TARGET="$(command -v "$choice")"
      # Ensure the target shell is listed in /etc/shells (required by chsh).
      if ! grep -qx "$TARGET" /etc/shells; then
        warn "$TARGET not in /etc/shells — adding (sudo)."
        echo "$TARGET" | $sudo_cmd tee -a /etc/shells
      fi
      info "Changing login shell to $choice (may prompt for password)…"
      $sudo_cmd chsh -s "$TARGET" "$USER_NAME"
      info "Shell changed. Please log out & back in to see the effect."
      break
      ;;
    Cancel)
      info "Shell change skipped."
      break
      ;;
    *)
      warn "Invalid option."
      ;;
    esac
  done
fi

# TODO: Remind the user to relogin (for shell env to update), or restart (for defaults to take effect).
# TODO: Remind the user to run restore_local to restore local files. New function to be added in the bin directory.

info "🎉  Bootstrap complete. Enjoy your new setup!"
