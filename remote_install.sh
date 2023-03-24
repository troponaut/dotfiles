#!/usr/bin/env bash
# Summary:
#   Install & setup this dotfiles repo
#
# Usage:
#   ./install.sh
#
# Environmenet Variables:
#   DOTFILES_DIR                        The target directory for the dotfiles repo
#   DOTFILES_INSTALL_USE_SUDO           Use sudo or not
#                                         Options: 0 (no) or 1 (yes)
#   DOTFILES_INSTALL_PACKAGE_MANAGER    Preferred pacakge manager (defaults based on OS)
#                                         Options: brew | nix | apt | dnf | yum | pacman
#
# Examples:
#   ./install.sh
#   DOTFILES_DIR="$HOME/my-dotfiles" ./install.sh
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/troponaut/dotfiles/master/install.sh)"

set -e

# Set these values so the installer can still run in color
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m' # green
COL_LIGHT_RED='\e[1;31m' # red
COL_LIGHT_YELLOW='\e[0;33m' #yellow
BOLD='\033[1m'
REGULAR='\033[0m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]" # Tick mark
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]" # Cross mark000
INFO="[${COL_LIGHT_YELLOW}i${COL_NC}]"
DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
OVER="\\r\\033[K"

# Override arguments or use
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_INSTALL_USE_SUDO="${DOTFILES_INSTALL_USE_SUDO:-1}"

get_os_family() {
  # ideally we would use an associative array here
  # but this needs to work in bash < v4 for macos
  os_info=(
    "/etc/auto_master::macos"
    "/etc/debian_version::debian"
    "/etc/fedora-release::fedora"
    "/etc/redhat-release::rhel"
    "/etc/arch-release::arch"
    "/etc/alpine-release::alpine"
  )
  for kv in "${os_info[@]}"; do
    key="${kv%%::*}"
    val="${kv##*::}"
    [[ -f "$key" ]] && os_family="${val}"
  done
  echo ${os_family}
  
}
 
install_prerequisites() {
  local pkgs="curl file git"

  case ${os_family} in
    "macos")
      if [[ ! -d "$(xcode-select -p)" ]]; then
        # Install XCode Command Line Tools.
        xcode-select --install &> /dev/null

        # Wait until XCode Command Line Tools installation has finished.
        until eval "$(xcode-select --print-path &> /dev/null)"; do
          sleep 5;
        done
      fi
      ;;
    "debian")
      $sudo_cmd apt update &&
        $sudo_cmd apt install -y build-essential &&
        $sudo_cmd apt install -y "${pkgs}"
      ;;
    "fedora")
      $sudo_cmd dnf groupinstall "Development Tools" &&
        $sudo_cmd dnf install -y libxcrypt-compat util-linux-user "${pkgs}"
      ;;
    "rhel")
      $sudo_cmd yum groupinstall "Development Tools" &&
        $sudo_cmd yum install -y "${pkgs}"
      ;;
    "arch")
      echo "pacman"
      $sudo_cmd pacman -S base-devel "${pkgs}" 
      ;;
    *)
      echo "OS family: '${os_family}' not supported"
      exit 1
      ;;
  esac
}

get_package_manager() {
  if [[ -n "$DOTFILES_INSTALL_PACKAGE_MANAGER" ]]; then
    echo "$DOTFILES_INSTALL_PACKAGE_MANAGER"
  else
    case ${os_family} in
      "macos") echo "brew" ;;
      "debian") echo "apt" ;;
      "fedora") echo "dnf" ;;
      "rhel") echo "yum" ;;
      "arch") echo "pacman" ;;
      *) ;;
    esac
  fi
}

install_package_managers() {
  case ${os_family} in
    "macos")
      # Always install homebrew on macos
      "${DOTFILES_DIR}/modules/homebrew/install.sh"
      ;;
    *) ;;
  esac

  if [[ "${pkg_mgr}" == "nix" ]]; then
    "${DOTFILES_DIR}/modules/nix/install.sh"
  fi
}

install_packages() {
  local pkgs="$1"

  case ${pkg_mgr} in
    "apt") $sudo_cmd apt install -y "$pkgs" ;;
    "dnf") $sudo_cmd dnf install -y "$pkgs" ;;
    "yum") $sudo_cmd yum install -y "$pkgs" ;;
    "pacman") $sudo_cmd pacman -S "$pkgs" ;;
    "brew")
      source "${DOTFILES_DIR}/modules/homebrew/.config/profile.d/homebrew.sh"
      # shellcheck disable=SC2086
      brew install $pkgs
      ;;
    "nix")
      source "${DOTFILES_DIR}/modules/nix/.config/profile.d/nix.sh"
      nix_pkgs=("$pkgs")
      # shellcheck disable=SC2068
      for pkg in ${nix_pkgs[@]}; do
        nix-env -iA nixpkgs."$pkg"
      done
      ;;
    *) ;;
  esac
}

install_brewfile(){
  # Install brews using brew bundle (uses the Brewfile)
  if [[ -x "$(command -v brew)" ]]; then
    printf "Do you want run brew bundle [y/N]? "
    read -r answer
    case "${answer}" in [yY] | [yY][eE][sS])
      brewfile="${DOTFILES_DIR}/modules/homebrew/.config/homebrew/Brewfile"
      HOMEBREW_BUNDLE_FILE="$brewfile" brew bundle
      ;;
    esac
  fi
}

install_prompt() {
  case ${pkg_mgr} in
    "apt") curl -sS https://starship.rs/install.sh | sh -s -- -y ;;    
    "brew") ## included in Brefile
    ;;
    *) install_packages "starship" ;;
  esac
}

register_zsh_users_repo() {
  local plugin="$1"

  case ${pkg_mgr} in
    "apt")
      debian_ver="11"
      echo "deb http://download.opensuse.org/repositories/shells:/zsh-users:/$plugin/Debian_$debian_ver/ /" | $sudo_cmd tee "/etc/apt/sources.list.d/shells:zsh-users:$plugin.list"
      curl -fsSL "https://download.opensuse.org/repositories/shells:zsh-users:$plugin/Debian_$debian_ver/Release.key" | gpg --dearmor | "$sudo_cmd tee /etc/apt/trusted.gpg.d/shells_zsh-users_$plugin.gpg" >/dev/null
      $sudo_cmd apt update
      ;;
    *) ;;
  esac
}

install_zsh_plugins() {
  plugins=("zsh-completions zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search")

  # shellcheck disable=SC2068
  for p in ${plugins[@]}; do
    register_zsh_users_repo "$p"
  done

  case ${pkg_mgr} in
    "apt")
      # TODO: Fix zsh-completions & zsh-history-substring-search on debian error even after registering
      plugins=("zsh-syntax-highlighting zsh-autosuggestions")
      ;;
    *) ;;
  esac

  install_packages "${plugins[@]}"
}

clone_dotfiles() {
  if [[ ! -d "${DOTFILES_DIR}" ]]; then
    # Clone this repo
    git clone "https://www.github.com/troponaut/dotfiles.git" ~/.dotfiles

    # Ensure repo is using the ssh remote
    pushd "${DOTFILES_DIR}" >/dev/null
    git remote set-url origin git@github.com:troponaut/dotfiles.git
    popd >/dev/null
  fi
}

# shellcheck disable=SC2317
setup_default_shells() {
  local bash_path
  bash_path="$(which bash | head -1)"
  local zsh_path
  zsh_path="$(which zsh | head -1)"

  if [[ "${os_family}" == "macos" ]]; then
    # Add available shells
    ! grep -q "${bash_path}" /etc/shells && echo "${bash_path}/bin/bash" | $sudo_cmd tee -a /etc/shells
    ! grep -q "${zsh_path}" /etc/shells && echo "${zsh_path}/bin/zsh" | $sudo_cmd tee -a /etc/shells
  fi

  # Change default shell to zsh
  chsh -s "$zsh_path"
}

# shellcheck disable=SC2317
backup_dotfiles() {
  # Rename existing dotfiles
  files=(~/.profile ~/.bash_profile ~/.bashrc ~/.zlogin ~/.zlogout ~/.zshenv ~/.zprofile ~/.zshrc)
  for file in "${files[@]}"; do
    if [[ -f "${file}" && ! -L "${file}" ]]; then
      mv "${file}" "${file}.bak"
    fi
  done
}


show_banner() {
  clear
cat << "EOF"
--------------------------------------------------
 _                                           _   
| |_ _ __ ___  _ __   ___  _ __   __ _ _   _| |_ 
| __| '__/ _ \| '_ \ / _ \| '_ \ / _` | | | | __|
| |_| | | (_) | |_) | (_) | | | | (_| | |_| | |_ 
 \__|_|  \___/| .__/ \___/|_| |_|\__,_|\__,_|\__|
              |_|                                

dotfiles for macOS & Linux

-------------------------------------------------- ∏
EOF

  printf "  %b Dotfiles target directory: ${BOLD}${DOTFILES_DIR}${REGULAR} \\n" "${TICK}"
  printf "  %b User: ${BOLD}${USER}${REGULAR} \\n" "${TICK}"
  printf "  %b OS family: ${BOLD}${os_family}${REGULAR} \\n" "${TICK}"
  printf "  %b Using Package Manager: ${BOLD}${pkg_mgr}${REGULAR} \\n\\n" "${TICK}"

}

main() {

  # get OS family & preferred package manager
  os_family=$(get_os_family)
  pkg_mgr="$(get_package_manager)"

  clear
  printf "\\n"
  show_banner


  # Prompt for admin password upfront
  sudo -v

  # sudo command
  sudo_cmd=""
  [[ "$DOTFILES_INSTALL_USE_SUDO" -eq 1 ]] && sudo_cmd="sudo "

  # pre-setup steps
  printf  "  %b Installing prerequisites...\\n" "${INFO}"
  install_prerequisites

  # clone the dotfiles (if needed)
  printf  "  %b Downloading and Cloning dotfiles...\\n" "${INFO}"
  clone_dotfiles && cd "$DOTFILES_DIR"


  # install packages
  printf  "  %b Setting up Package Manager: ${BOLD}${pkg_mgr}${REGULAR}...\\n" "${INFO}"
  install_package_managers

  base_pkgs="stow zsh"
  printf  "  %b Installing: ${BOLD}${base_pkgs}${REGULAR} \\n" "${INFO}"
  install_packages "$base_pkgs"
  
  show_banner
  printf  "  %b All prerequisites installed \\n" "${TICK}"
  printf  "  %b Dotfiles cloned at ${BOLD}${DOTFILES_DIR}${REGULAR}\\n" "${TICK}"
  printf  "  %b Package Manager ${BOLD}${pkg_mgr}${REGULAR} is ready! \\n" "${TICK}"
  printf  "  %b Packages Installed: ${BOLD}${base_pkgs}${REGULAR} \\n" "${TICK}"

  install_brewfile
  printf  "  %b Installing Brefile: ${BOLD}${HOMEBREW_BUNDLE_FILE}${REGULAR} \\n" "${TICK}"

  # configure default shell
  # printf  "  %b Setting default shell \\n" "${TICK}"
  # setup_default_shells

  printf  "  %b Installing ZSH plugins \\n" "${TICK}"
  install_zsh_plugins

  printf  "  %b Installing prompt \\n" "${TICK}"
  install_prompt

  printf  "  %b Running Makefile \\n" "${TICK}"
  make

  show_banner
  printf  "  %b All prerequisites installed \\n" "${TICK}"
  printf  "  %b Dotfiles cloned at ${BOLD}${DOTFILES_DIR}${REGULAR}\\n" "${TICK}"
  printf  "  %b Package Manager ${BOLD}${pkg_mgr}${REGULAR} is ready! \\n" "${TICK}"
  printf  "  %b Packages Installed: ${BOLD}${base_pkgs}${REGULAR} \\n" "${TICK}"
  printf  "  %b Installed Brefile: ${BOLD}${HOMEBREW_BUNDLE_FILE}${REGULAR} \\n" "${TICK}"
  printf  "\\n"
  printf  "\\n"
  printf  "  %b ${BOLD}All Done - Restart terminal \\n${REGULAR}" "${TICK}"  
}

# Run the script
main "$@"
exit 0
