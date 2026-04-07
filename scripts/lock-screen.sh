#!/usr/bin/env bash
set -euo pipefail

if command -v swaylock >/dev/null 2>&1; then
    exec swaylock \
        --screenshots \
        --clock \
        --timestr '%H:%M' \
        --datestr '%A, %B %-d' \
        --font-size 52 \
        --text-color ffffff \
        --text-ver-color ffffff \
        --text-clear-color ffffff \
        --text-wrong-color ffffff \
        --text-caps-lock-color ffffff \
        --ring-color 00000000 \
        --line-color 00000000 \
        --inside-color 00000000 \
        --key-hl-color 00000000 \
        --effect-blur 7x5 \
        --effect-greyscale \
        --effect-vignette 0.4:0.7
fi

echo "swaylock is not installed." >&2
exit 1