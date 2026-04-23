#!/usr/bin/env bash
set -euo pipefail

FUZZEL_CONFIG="${HOME}/.config/niri/fuzzel/fuzzel.ini"
SCRIPT_DIR="${HOME}/.config/niri/scripts"

options=(
    "Session Menu"
    "Power Profile Menu"
    "Wallpaper Selector"
    "DNS Menu"
    "Lock Screen"
)

choice="$(printf "%s\n" "${options[@]}" | fuzzel --dmenu --config "${FUZZEL_CONFIG}" --prompt "Settings> ")"

case "${choice}" in
    "Session Menu")
        exec "${SCRIPT_DIR}/session-menu.sh"
        ;;
    "Power Profile Menu")
        exec "${SCRIPT_DIR}/power-profile-menu.sh"
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
    *)
        exit 0
        ;;
esac