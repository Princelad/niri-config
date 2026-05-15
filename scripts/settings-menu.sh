#!/usr/bin/env bash
set -euo pipefail

FUZZEL_CONFIG="${HOME}/.config/niri/fuzzel/fuzzel.ini"
SCRIPT_DIR="${HOME}/.config/niri/scripts"

options=(
    "Session Menu"
    "Power Profile Menu"
    "Display Management"
    "Wallpaper Selector"
    "DNS Menu"
    "Lock Screen"
    "Toggle Idle Inhibit"
)

choice="$(printf "%s\n" "${options[@]}" | fuzzel --dmenu --config "${FUZZEL_CONFIG}" --prompt "Settings> ")"

case "${choice}" in
    "Session Menu")
        exec "${SCRIPT_DIR}/session-menu.sh"
        ;;
    "Power Profile Menu")
        exec "${SCRIPT_DIR}/power-profile-menu.sh"
        ;;
    "Display Management")
        exec "${SCRIPT_DIR}/display-menu.sh"
        ;;
    "Wallpaper Selector")
        exec "${SCRIPT_DIR}/wallpaper-selector.sh"
        ;;
    "DNS Menu")
        exec "${SCRIPT_DIR}/dns-menu.sh"
        ;;
    "Lock Screen")
        exec "${SCRIPT_DIR}/lock-screen.sh"
        ;;
    "Toggle Idle Inhibit")
        exec "${SCRIPT_DIR}/idle-inhibit.sh" toggle
        ;;
    *)
        exit 0
        ;;
esac