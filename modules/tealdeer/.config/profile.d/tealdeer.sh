#
# Initialize tealdeer
#
# - https://github.com/dbrgn/tealdeer
#

# shellcheck disable=SC1090

if [[ ! -d "${XDG_DATA_HOME}/tealdeer/pages" ]]; then
  mkdir -p "${XDG_DATA_HOME}/tealdeer/pages/custom-pages"
fi
