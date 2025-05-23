# --------------------------------------------------------------
# Various utility functions
#
# These are used by other packages so this file must be
# sourced before other packages are loaded.
# --------------------------------------------------------------

if [ -n "${ZSH_VERSION}" ]; then
  # Do not throw errors when file globs do not match anything
  setopt NULL_GLOB
fi

#
# Check if a command exists
#
# usage:
#   command_exists "command"
#
# example:
#   command_exists "node" && echo "exists!"
#
function command_exists() {
  # use fastest shell specific method
  # shellcheck disable=SC1009
  if [ -n "$ZSH_VERSION" ]; then
    # shellcheck disable=SC2193,SC2203
    [[ $+commands[$1] == 1 ]]
  else
    command -v "$1" >/dev/null 2>&1
  fi
}

#
# Checks if a function exists
#
# usage:
#   function_exists "func_name"
#
# example:
#   function_exists "command_exists" && echo "exists!"
#
function function_exists() {
  # declare -f -F "$1" > /dev/null 2>&1
  typeset -f "$1" >/dev/null 2>&1
}

#
# Prepends a path to the path variable (avoiding duplicates)
#
# usage:
#   prepend_path [path_to_prepend]
#   prepend_path [first_path] [second_path]
#
# examples:
#   prepend_path "/some/path"
#   # PATH="/some/path:/usr/bin:/bin"
#
#   prepend_path "/path/abc" "/path/xyz"
#   # PATH="/path/abc:/path/xyz:/usr/bin:/bin"
function prepend_path() {
  local i
  local dir
  for (( i=$#; i>=1; i-- )); do
    dir="${@:$i:1}" # ${array:offset:length} → POSIX-y in both shells
    [[ -d $dir ]] || continue
    if [[ -n ${ZSH_VERSION-} ]]; then
      path=("$dir" $path) # duplicate check is done by zsh typeset -U path
    else
      case ":$PATH:" in
        *":$dir:"*) ;;
        *) PATH="$dir:$PATH" ;;
      esac
    fi
  done
}

#
# Appends paths to the path variable (avoiding duplicates)
#
# usage:
#   append_path [path_to_append]
#   append_path [first_path] [second_path]
#
# examples:
#   append_path "/some/path"
#   # PATH="/usr/bin:/bin:/some/path"
#
#   append_path "/path/abc" "/path/xyz"
#   # PATH="/usr/bin:/bin:/path/abc:/path/xyz"
#
function append_path() {
  local arg
  for arg in "$@"; do
    if [ -d "$arg" ] && [[ ":$PATH:" != *":$arg:"* ]]; then
      debug "Appending path: $arg"
      PATH="${PATH:+"$PATH:"}$arg"
    fi
  done
}

#
# Prepends a fpath to the fpath variable (avoiding duplicates)
#
# usage:
#   prepend_fpath [fpath_to_prepend]
#   prepend_fpath [first_fpath] [second_fpath]
#
# examples:
#   prepend_fath "/some/fpath"
#   # FPATH="/some/fpath:/usr/bin:/bin"
#
#   prepend_pfath "/fpath/abc" "/fpath/xyz"
#   # FPATH="/fpath/abc:/fpath/xyz:/usr/bin:/bin"
#
function prepend_fpath() {
  local i
  local dir
  for (( i=$#; i>=1; i-- )); do
    dir="${@:$i:1}" # ${array:offset:length} → POSIX-y in both shells
    [[ -d $dir ]] || continue
    if [[ -n ${ZSH_VERSION-} ]]; then
      fpath=("$dir" $fpath) # duplicate check is done by zsh typeset -U path
    else
      case ":$FPATH:" in
        *":$dir:"*) ;;
        *) FPATH="$dir:$FPATH" ;;
      esac
    fi
  done
}

#
# Appends fpaths to the fpath variable (avoiding duplicates)
#
# usage:
#   append_fpath [fpath_to_append]
#   append_fpath [first_fpath] [second_fpath]
#
# examples:
#   append_fpath "/some/fpath"
#   # FPATH="/usr/bin:/bin:/some/fpath"
#
#   append_path "/path/abc" "/path/xyz"
#   # FPATH="/usr/bin:/bin:/fpath/abc:/fpath/xyz"
#
function append_fpath() {
  local arg
  for arg in "$@"; do
    if [ -d "$arg" ] && [[ ":$FPATH:" != *":$arg:"* ]]; then
      FPATH="${FPATH:+"$FPATH:"}$arg"
    fi
  done
}


#
# Prints the PATH variable with each entry on a new line
#
# usage:
#   print_path
#
# examples:
#   print_path
#   # PATH:
#   #   /usr/local/bin
#   #   /usr/bin
#   #   /bin
#
function print_path() {
  local path_list
  path_list=$(printf '%s\n' ${(s/:/)PATH} | sed 's|^|  |')
  echo "PATH:"
  echo "$path_list"
}

#
# Prints the fpath array with each entry on a new line
#
# usage:
#   print_fpath
#
# examples:
#   print_fpath
#   # fpath:
#   #   /usr/local/share/zsh/site-functions
#
function print_fpath() {
  local fpath_list
  fpath_list=$(printf '%s\n' "${fpath[@]}" | sed 's|^|  |')
  echo "fpath:"
  echo "$fpath_list"
}

#
# Sources files only once
#
# examples:
#   source_file "/path/to/file.sh"
#
__SOURCED_FILES=()
source_file() {
  local file=$1
  if [ -f "${file}" ] && [[ ! "${__SOURCED_FILES[*]}" =~ ${file} ]]; then
    source "$file"
    __SOURCED_FILES+=("${file}")
  fi
}

#
# Sources files in a glob
#
# examples:
#   source_files_in ${XDG_CONFIG_HOME}/profile.d/*.sh
#
source_files_in() {
  for file in "$@"; do
    if [ -n "$PROFILE_STARTUP" ]; then
      # eval function name for profiling
      fn=$(basename "$file")
      eval "$fn() { source_file $file }; $fn"
    else
      source_file "$file"
    fi
  done

  unset file
}

#
# Source a shared library module (once)
#
# examples:
#   source_shell_lib "some_lib"
#
source_shell_lib() {
  # module="$1"
  file="${HOME}/.local/lib/${1}.sh"
  source_file "$file"
}

#
# lazy load function helper
#
# usage:
#   lazyfunc [lazy_function] [commands_to_hook...]
#
# example:
#   lazyfunc _nodenv_init nodenv node npm
#
# example:
#   # Detailed example using pyenv
#   export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
#
#   _pyenv_init() {
#     # expensive operation
#     eval "$(pyenv init - --no-rehash)"
#
#     # Rehash in the background
#     # (pyenv rehash &) 2> /dev/null
#   }
#
#   _pyenv_lazy_init() {
#     unset -f "$0"
#
#     # faster alternative to full 'pyenv init'
#     export PYENV_SHELL="${SHELL_TYPE:-$SHELL}"
#     prepend_path "${PYENV_ROOT}/shims"
#
#     # lazy initialize
#     lazyfunc _pyenv_init pyenv
#   }
#
#   # Load package manager installed pyenv into shell session
#   if command_exists "pyenv"; then
#     _pyenv_lazy_init
#
#   # Load manually installed pyenv into the shell session
#   elif [ -s "${PYENV_ROOT}/bin/pyenv" ]; then
#     prepend_path "${PYENV_ROOT}/bin"
#     _pyenv_lazy_init
#
#   # Return if requirements not found
#   else
#     unset PYENV_ROOT
#     unset -f _pyenv_lazy_init
#     unset -f _pyenv_init
#     return 1
#   fi
#
function lazyfunc() {
  local lazyfunc="$1"
  local hooks=("${@:2}")

  for cmd in "${hooks[@]}"; do
    eval "${cmd}() { __lazyfunc_exec ${lazyfunc} ${hooks[*]}; ${cmd} \$@; }"
  done
}

#
# lazy load function executor
#
# usage:
#   __lazyfunc_exec [lazy_function] [commands_to_hook...]
#
__lazyfunc_exec() {
  local lazyfunc=$1
  local hooks=("${@:2}")
  unset -f "${hooks[@]}"
  eval "${lazyfunc}"
  unset "${lazyfunc}"
}
