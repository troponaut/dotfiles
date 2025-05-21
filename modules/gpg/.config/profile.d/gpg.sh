#
# GnuPG environment
#

# XDG specification
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

# Ensure git will work with gpg v2
# shellcheck disable=SC2016
export GPG_TTY='$(tty)'
