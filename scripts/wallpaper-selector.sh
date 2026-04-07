#!/usr/bin/env bash
set -euo pipefail

wallpaper_dir="${WALLPAPERDIR:-${HOME}/Wallpapers}"

if [[ ! -d "${wallpaper_dir}" ]]; then
    notify-send "Wallpaper" "Directory not found: ${wallpaper_dir}"
    exit 1
fi

current=""
if [[ -f "${HOME}/.cache/wal/wal" ]]; then
    current=$(basename "$(cat "${HOME}/.cache/wal/wal")")
fi

mapfile -t files < <(find "${wallpaper_dir}" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.gif" \) \
    -printf "%f\n" | sort)

if [[ ${#files[@]} -eq 0 ]]; then
    notify-send "Wallpaper" "No image files found in ${wallpaper_dir}"
    exit 1
fi

choice=$(printf "%s\n" "${files[@]}" | fuzzel --dmenu --config "${HOME}/.config/niri/fuzzel/fuzzel.ini" --prompt "Wallpaper> ")

if [[ -z "${choice}" ]]; then
    exit 0
fi

image="${wallpaper_dir}/${choice}"
if [[ ! -f "${image}" ]]; then
    notify-send "Wallpaper" "Selection not found: ${choice}"
    exit 1
fi

wal -i "${image}" >/dev/null 2>&1
notify-send "Wallpaper" "Applied: ${choice}"
