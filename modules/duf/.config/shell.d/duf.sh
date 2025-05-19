#
# Initialize duf aliases
#

function df() {
  if [[ "$1" == "--df" ]]; then
    shift
    /bin/df "$@"
  else
    duf "$@"
  fi
}

# TODO: df Completions
