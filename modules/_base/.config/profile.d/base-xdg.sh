#!/usr/bin/env bash
#
# Setup misc xdg specifications not in other modules
#   https://wiki.archlinux.org/title/XDG_Base_Directory
#

# CocoaPods
export CP_HOME_DIR="${XDG_DATA_HOME}/cocoapods"

# Gradle
export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"

# Wget
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
alias wget='wget --hsts-file="${XDG_CACHE_HOME}/wget-hsts"'
