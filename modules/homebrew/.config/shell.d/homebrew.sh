#
# Initialize homebrew helpers
#
# - https://brew.sh
# - https://docs.brew.sh/Homebrew-on-Linux
#

# Check requirements
if ! command_exists "brew"; then
  return 1
fi

#
# Aliases
#

# Homebrew
alias brewb='brew bundle'
alias brewc='brew cleanup'
alias brewi='brew install'
alias brewl='brew list'
alias brewo='brew outdated'
alias brewr='brew remove'
alias brews='brew search'
alias brewu='brew uninstall'

# Dependencies
alias brew-deps='brew deps --installed'
alias brew-leaves='brew leaves'
alias brew-uses='brew uses --installed'

# Composite upgrade aliases
alias brew-upgrade='brew update && brew bundle && brew upgrade --greedy && brew cleanup'
alias brewupg='brew-upgrade'

# Brewfile editor function
# This function allows you to edit the Brewfile or a specific Brewfile.* file.

brewed() {
  # Check if HOMEBREW_BUNDLE_FILE is defined
  if [ -z "${HOMEBREW_BUNDLE_FILE}" ]; then
    echo "HOMEBREW_BUNDLE_FILE is not set."
    return 1
  fi

  # If first argument is -e or --editor, use $EDITOR; otherwise, use $VISUAL.
  local editor_cmd
  if [[ $1 == -e || $1 == --editor ]]; then
    editor_cmd=${EDITOR:-vi}
    shift
  else
    editor_cmd=${VISUAL:-vi}
  fi

  usage() {
    echo "USAGE: brewed [(-e|--editor)] [<brewfile>]"
    echo
    echo "OPTIONS:"
    echo "  no args       Show this help message"
    echo "  all           Open the Brewfile directory"
    echo "  <brewfile>    Edit a specific Brewfile.<brewfile>"
    echo "  help, -h      Show this help message"
    echo
    echo "ARGUMENTS:"
    echo "  -e, --editor  Use \$EDITOR instead of \$VISUAL"
  }

  # return usage if no args
  [[ -z $1 ]] && {
    usage
    return 1
  }

  case "$1" in
  all)
    $editor_cmd "$(dirname "$HOMEBREW_BUNDLE_FILE")"
    ;;
  help | h | -h | --help)
    usage
    ;;
  *)
    $editor_cmd "$(dirname "$HOMEBREW_BUNDLE_FILE")/Brewfile.$1"
    ;;
  esac
}

_brewed() {
  local -a completions
  # Fixed options: include editor flags and help.
  completions=("all")

  # Dynamically add completions from Brewfile.* files.
  local file base suffix
  for file in "$XDG_CONFIG_HOME/homebrew"/Brewfile.*; do
    if [ -f "$file" ]; then
      base=$(basename "$file")
      # Remove the "Brewfile." prefix to get the extension.
      suffix=${base#Brewfile.}
      completions+=("$suffix")
    fi
  done

  compadd -U -- "${completions[@]}"
}

compdef _brewed brewed
