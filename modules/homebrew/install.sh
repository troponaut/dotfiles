#!/usr/bin/env bash
#
# Setup homebrew
#

set -e

# Prompt for admin password upfront
sudo -v

# Check if homebrew is installed
if [[ ! -x "$(command -v brew)" ]]; then
  if [[ "${OSTYPE}" == darwin* ]]; then
    # Install standard homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
  elif [[ "${OSTYPE}" == linux* ]]; then
  
    # Make sure this is in the path
    if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/bin* ]]; then
      PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
    fi

    # Install linuxbrew
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi