#!/usr/bin/env bash
set -euo pipefail

FUZZEL_CONFIG="${HOME}/.config/niri/fuzzel/fuzzel.ini"

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Display" "$1"
    fi
}

choose() {
    local prompt="$1"
    fuzzel --dmenu --config "${FUZZEL_CONFIG}" --prompt "${prompt}> "
}

require_tools() {
    if ! command -v niri >/dev/null 2>&1; then
        notify "Error: niri is not available"
        exit 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        notify "Error: python3 is not available"
        exit 1
    fi
}

list_outputs() {
    NIRI_OUTPUTS_JSON="$(niri msg --json outputs)" python3 - <<'PY'
import json
import os

data = json.loads(os.environ["NIRI_OUTPUTS_JSON"])

for name in sorted(data, key=str.lower):
    info = data[name]
    modes = info.get("modes") or []
    current_index = info.get("current_mode")
    current_mode = None
    if isinstance(current_index, int) and 0 <= current_index < len(modes):
        current_mode = modes[current_index]

    logical = info.get("logical") or {}
    scale = logical.get("scale", "auto")
    transform = str(logical.get("transform", "normal")).lower()

    if current_mode is None:
        status = "off"
        mode = "auto"
    else:
        status = "on"
        refresh = current_mode.get("refresh_rate")
        if isinstance(refresh, (int, float)):
            refresh_text = f"{refresh / 1000:.3f}"
        else:
            refresh_text = "auto"
        mode = f"{current_mode.get('width')}x{current_mode.get('height')}@{refresh_text}"

    print(f"{name}\t{status}; mode={mode}; scale={scale}; transform={transform}")
PY
}

output_info() {
    local output_name="$1"
    NIRI_OUTPUTS_JSON="$(niri msg --json outputs)" OUTPUT_NAME="${output_name}" python3 - <<'PY'
import json
import os

data = json.loads(os.environ["NIRI_OUTPUTS_JSON"])
info = data[os.environ["OUTPUT_NAME"]]

modes = info.get("modes") or []
current_index = info.get("current_mode")
current_mode = None
if isinstance(current_index, int) and 0 <= current_index < len(modes):
    current_mode = modes[current_index]

logical = info.get("logical") or {}
scale = logical.get("scale", "auto")
transform = str(logical.get("transform", "normal")).lower()

if current_mode is None:
    mode = "auto"
else:
    refresh = current_mode.get("refresh_rate")
    if isinstance(refresh, (int, float)):
        refresh_text = f"{refresh / 1000:.3f}"
    else:
        refresh_text = "auto"
    mode = f"{current_mode.get('width')}x{current_mode.get('height')}@{refresh_text}"

print(f"status={('off' if current_mode is None else 'on')}\nmode={mode}\nscale={scale}\ntransform={transform}")
PY
}

choose_mode() {
    local output_name="$1"
    NIRI_OUTPUTS_JSON="$(niri msg --json outputs)" OUTPUT_NAME="${output_name}" python3 - <<'PY'
import json
import os

data = json.loads(os.environ["NIRI_OUTPUTS_JSON"])
info = data[os.environ["OUTPUT_NAME"]]

modes = info.get("modes") or []
current_index = info.get("current_mode")

for index, mode in enumerate(modes):
    refresh = mode.get("refresh_rate")
    if isinstance(refresh, (int, float)):
        refresh_text = f"{refresh / 1000:.3f}"
    else:
        refresh_text = "auto"

    label = f"{mode.get('width')}x{mode.get('height')}@{refresh_text}"
    if index == current_index:
        label = f"{label} *"

    print(label)

print("auto")
PY
}

choose_scale() {
    local output_name="$1"
    local current_scale
    current_scale="$(output_info "${output_name}" | awk -F= '/^scale=/{print $2}')"

    printf '%s\n' \
        "auto" \
        "0.75" \
        "1" \
        "1.25" \
        "1.5" \
        "1.75" \
        "2" \
        "${current_scale} *"
}

choose_transform() {
    local output_name="$1"
    local current_transform
    current_transform="$(output_info "${output_name}" | awk -F= '/^transform=/{print $2}')"

    printf '%s\n' \
        "normal" \
        "90" \
        "180" \
        "270" \
        "flipped" \
        "flipped-90" \
        "flipped-180" \
        "flipped-270" \
        "${current_transform} *"
}

apply_output_action() {
    local output_name="$1"
    local action="$2"

    case "${action}" in
        "Toggle Power")
            local status
            status="$(output_info "${output_name}" | awk -F= '/^status=/{print $2}')"
            if [[ "${status}" == "off" ]]; then
                niri msg output "${output_name}" on
            else
                niri msg output "${output_name}" off
            fi
            ;;
        "Set Mode")
            local mode
            mode="$(choose_mode "${output_name}" | choose "Mode" | sed 's/ \*$//')"
            [[ -z "${mode}" ]] && exit 0
            niri msg output "${output_name}" mode "${mode}"
            ;;
        "Set Scale")
            local scale
            scale="$(choose_scale "${output_name}" | choose "Scale" | sed 's/ \*$//')"
            [[ -z "${scale}" ]] && exit 0
            niri msg output "${output_name}" scale "${scale}"
            ;;
        "Set Transform")
            local transform
            transform="$(choose_transform "${output_name}" | choose "Transform" | sed 's/ \*$//')"
            [[ -z "${transform}" ]] && exit 0
            niri msg output "${output_name}" transform "${transform}"
            ;;
        *)
            exit 0
            ;;
    esac
}

main() {
    require_tools

    local output_line output_name output_choice action
    output_line="$(list_outputs | choose "Display")"
    [[ -z "${output_line}" ]] && exit 0

    output_name="${output_line%%$'\t'*}"
    output_choice="$(output_info "${output_name}")"

    action="$(printf '%s\n' \
        "Toggle Power" \
        "Set Mode" \
        "Set Scale" \
        "Set Transform" \
        | choose "${output_name}")"

    [[ -z "${action}" ]] && exit 0

    apply_output_action "${output_name}" "${action}"
}

main "$@"