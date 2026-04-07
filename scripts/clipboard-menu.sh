#!/usr/bin/env bash
set -euo pipefail

FUZZEL_CONFIG="${HOME}/.config/niri/fuzzel/fuzzel.ini"
CLEAR_LABEL="[Clear Clipboard History]"

if ! command -v cliphist >/dev/null 2>&1; then
    exit 1
fi

if ! command -v wl-copy >/dev/null 2>&1; then
    exit 1
fi

if ! entries="$(cliphist list 2>/dev/null)"; then
    entries=""
fi

selection="$({
    printf "%s\n" "${CLEAR_LABEL}"
    if [[ -n "${entries}" ]]; then
        printf "%s\n" "${entries}"
    fi
} | fuzzel --dmenu --config "${FUZZEL_CONFIG}" --prompt "Clipboard> ")"

if [[ -z "${selection}" ]]; then
    exit 0
fi

if [[ "${selection}" == "${CLEAR_LABEL}" ]]; then
    cliphist wipe
    exit 0
fi

action="$(printf "Copy\nDelete\n" | fuzzel --dmenu --config "${FUZZEL_CONFIG}" --prompt "Action> ")"

case "${action}" in
    Copy)
        cliphist decode <<< "${selection}" | wl-copy
        ;;
    Delete)
        cliphist delete <<< "${selection}"
        ;;
esac
