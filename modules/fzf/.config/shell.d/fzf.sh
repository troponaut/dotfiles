#
# Fuzzy finder (fzf)
#
# - https://github.com/junegunn/fzf
#

# shellcheck disable=SC1090

# Skip if not using fzf (default is fzf)
FUZZY_FINDER="${FUZZY_FINDER:-fzf}"
[ "${FUZZY_FINDER}" != "fzf" ] && return 1

# # The install directory
# if [ -d "${PROFILE_PREFIX}/opt/fzf" ]; then
#   _FZF_DIR="${PROFILE_PREFIX}/opt/fzf"
# elif [ -d "/usr/local/opt/fzf" ]; then
#   _FZF_DIR="/usr/local/opt/fzf"
# elif [ -d "${XDG_DATA_HOME}/fzf" ]; then
#   _FZF_DIR="${XDG_DATA_HOME}/fzf"
# else
#   return 1
# fi

eval "$(fzf --zsh)"


# Default options
export FZF_DEFAULT_OPTS="--height 100% --layout=reverse --inline-info --preview 'preview {} | head -n 500'"

# Use ripgrep
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"

# Keybindings
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Options
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --preview 'bat --style=numbers --color=always --line-range :500 {}'"

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target,bin
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --preview 'eza --tree --color=always {} | head -200'"


# export FZF_CTRL_R_OPTS=""


#
# Completions
#

# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='~~'
# export FZF_COMPLETION_TRIGGER='**'

# Completion options for fzf command
# export FZF_COMPLETION_OPTS=''

# Command for listing path candidates
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Faster compgen
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd) fzf "$@" --preview 'eza --tree --color=always {} | head -200' ;;
    export | unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh) fzf "$@" --preview 'dig {}' ;;
    *) fzf "$@" --preview 'bat --style=numbers --color=always --line-range :500 {}' ;;
  esac
}