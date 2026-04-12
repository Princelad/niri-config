#!/usr/bin/env bash
set -euo pipefail

# Helper to extract hex color from pywal colorscheme.json
get_pywal_color() {
    local color_name="$1"
    local default_color="${2:-ffffff}"

    local wal_file="${HOME}/.config/wal/colorscheme.json"
    if [[ -f "$wal_file" ]]; then
        jq -r ".colors.\"$color_name\" // \"#${default_color}\"" "$wal_file" 2>/dev/null | sed 's/#//' || echo "$default_color"
    else
        echo "$default_color"
    fi
}

# Check if swaylock is available
if ! command -v swaylock >/dev/null 2>&1; then
    echo "swaylock is not installed." >&2
    exit 1
fi

# Check if jq is available for JSON parsing
if ! command -v jq >/dev/null 2>&1; then
    echo "jq is not installed (required for pywal integration)." >&2
    echo "Falling back to default colors..." >&2
fi

# Extract colors from pywal (or use sensible defaults)
TEXT_COLOR=$(get_pywal_color "color7" "ffffff")           # Foreground/text
ACCENT_COLOR=$(get_pywal_color "color4" "00bfff")         # Highlight color
ERROR_COLOR=$(get_pywal_color "color1" "ff0000")           # Error/wrong color
BACKGROUND_COLOR=$(get_pywal_color "color0" "000000")      # Background

# Execute swaylock with pywal-integrated colors
exec swaylock \
    --screenshots \
    --clock \
    --timestr '%H:%M' \
    --datestr '%A, %B %-d' \
    --font-size 42 \
    --text-color "$TEXT_COLOR" \
    --text-ver-color "$ACCENT_COLOR" \
    --text-clear-color "$TEXT_COLOR" \
    --text-wrong-color "$ERROR_COLOR" \
    --text-caps-lock-color "$ACCENT_COLOR" \
    --ring-color "${ACCENT_COLOR}33" \
    --line-color "${ACCENT_COLOR}00" \
    --inside-color "${BACKGROUND_COLOR}00" \
    --key-hl-color "$ACCENT_COLOR" \
    --bs-hl-color "$ERROR_COLOR" \
    --effect-blur 7x5 \
    --effect-vignette 0.4:0.7 \
    --fade-in 0.2