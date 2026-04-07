#!/usr/bin/env bash
set -euo pipefail

SRC="${HOME}/Desktop"
DEST="${HOME}/.local/share/applications"

mkdir -p "${DEST}"

# Keep desktop launchers visible to fuzzel drun by syncing symlinks.
find "${DEST}" -type l -name "desktop-*.desktop" -delete

shopt -s nullglob
for file in "${SRC}"/*.desktop; do
    if grep -q "^Exec=" "${file}"; then
        name=$(basename "${file}")
        ln -sf "${file}" "${DEST}/desktop-${name}"
    fi
done

exec fuzzel --config "${HOME}/.config/niri/fuzzel/fuzzel.ini"
