#!/usr/bin/env bash
#
# Bash Completion
#

# Load bash completions
if [ -e "${PROFILE_PREFIX}/share/bash-completion/bash_completion" ]; then
  export BASH_COMPLETION_COMPAT_DIR="${PROFILE_PREFIX}/etc/bash_completion.d"
  # shellcheck disable=SC1091
  source_file "${PROFILE_PREFIX}/share/bash-completion/bash_completion"
elif [ -e "${PROFILE_PREFIX}/etc/profile.d/bash_completion.sh" ]; then
  # shellcheck disable=SC1091
  source_file "${PROFILE_PREFIX}/etc/profile.d/bash_completion.sh"
elif [ -e "/etc/bash_completion" ]; then
  # shellcheck disable=SC1091
  source_file "/etc/bash_completion"
fi

# Load custom completions
if [ -d "${XDG_DATA_HOME}/bash_completion.d" ]; then
  for file in "${XDG_DATA_HOME}"/bash_completion.d/*; do
    # shellcheck disable=SC1090
    source_file "$file"
  done
fi
