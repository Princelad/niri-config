#!/usr/bin/env bash
set -euo pipefail

options=$(cat <<'EOF'
Lock
Logout
Suspend
Reboot
Shutdown
EOF
)

choice=$(printf "%s\n" "${options}" | fuzzel --dmenu --config "${HOME}/.config/niri/fuzzel/fuzzel.ini" --prompt "Session> ")

case "${choice}" in
    Lock)
        "${HOME}/.config/niri/scripts/lock-screen.sh"
        ;;
    Logout)
        niri msg action quit
        ;;
    Suspend)
        systemctl suspend
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
esac
