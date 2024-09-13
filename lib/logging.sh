# lib/logging.sh

# Constant to control global logging
ENABLE_LOGGING="${DOTFILES_LOGGING:-1}"

echo_log() {
  if [ "$ENABLE_LOGGING" -eq 1 ]; then
    echo -e "\033[1;34;4m[LOG] $1\033[0m"
  fi
}