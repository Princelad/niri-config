#!/usr/bin/env bash
set -euo pipefail

if ! command -v swayidle >/dev/null 2>&1; then
    echo "swayidle is not installed." >&2
    exit 1
fi

# Avoid duplicate idle daemons if startup hooks are re-run.
pkill -x swayidle >/dev/null 2>&1 || true

exec swayidle -w \
    timeout 300 "$HOME/.config/niri/scripts/lock-screen.sh" \
    timeout 900 "systemctl suspend" \
    before-sleep "$HOME/.config/niri/scripts/lock-screen.sh"
