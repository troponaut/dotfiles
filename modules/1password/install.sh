#!/usr/bin/env bash

set -e

manage_1password_mac_launch_agent() {
  case "$1" in
  enable)
    if ! launchctl list | grep -q "$(basename "$2" .plist)"; then
      launchctl load -w "$2"
    fi
    ;;
  disable)
    if launchctl list | grep -q "$(basename "$2" .plist)"; then
      launchctl unload -w "$2"
      rm "$2"
    fi
    ;;
  *)
    echo "Usage: manage_1password_mac_launch_agent {enable|disable} <plist_path>"
    return 1
    ;;
  esac
}

configure_1password_macos_ssh_agent() {

  # 1password agent is installed in ~/.1password/agent.sock
  # $HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  mkdir -p ~/Library/LaunchAgents

  cat <<EOF >~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.1password.SSH_AUTH_SOCK</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>-c</string>
    <string>/bin/ln -sf $HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \$SSH_AUTH_SOCK</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF

  manage_1password_mac_launch_agent enable ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
}


main() {
  case "$("$DOTFILES_BIN"/os-info --family)" in
  "macos")
    configure_1password_macos_ssh_agent
    ;;
  "debian")
    # onfigure_1password_linux_ssh_agent
    ;;
  *) ;;
  esac
}

main "$@"
