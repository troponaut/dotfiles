#
# Initialize kitty helpers
# https://sw.kovidgoyal.net/kitty/kittens_intro/
#

# Check requirements
if ! command_exists "kitten"; then
  return 1
fi

#
# Aliases
#

# kitten ssh
alias s='kitten ssh'
