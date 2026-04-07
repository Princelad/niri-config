#!/usr/bin/env bash
set -euo pipefail

current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

ps="power-saver"
bd="balanced"
pf="performance"

[[ "${current}" == "power-saver" ]] && ps="${ps} *"
[[ "${current}" == "balanced" ]] && bd="${bd} *"
[[ "${current}" == "performance" ]] && pf="${pf} *"

options=$(printf "%s\n%s\n%s\n" "${ps}" "${bd}" "${pf}")

choice=$(printf "%s\n" "${options}" | fuzzel --dmenu --config "${HOME}/.config/niri/fuzzel/fuzzel.ini" --prompt "Power> ")
choice=${choice%% *}

case "${choice}" in
    power-saver|balanced|performance)
        powerprofilesctl set "${choice}"
        ;;
esac
