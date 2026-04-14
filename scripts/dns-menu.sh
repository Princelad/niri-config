#!/usr/bin/env bash
set -euo pipefail

FUZZEL_CONFIG="${HOME}/.config/niri/fuzzel/fuzzel.ini"

notify() {
    local message="$1"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "DNS Menu" "${message}"
    fi
}

if ! command -v nmcli >/dev/null 2>&1; then
    notify "Error: nmcli not installed"
    exit 1
fi

active_connection="$(nmcli -t -f NAME connection show --active | head -n1)"
if [[ -z "${active_connection}" ]]; then
    notify "No active NetworkManager connection"
    exit 1
fi

current_dns="$(nmcli -g ipv4.dns connection show "${active_connection}" 2>/dev/null | tr '; ' ',' | sed 's/,,*/,/g; s/^,//; s/,$//')"
current_ignore_auto="$(nmcli -g ipv4.ignore-auto-dns connection show "${active_connection}" 2>/dev/null || echo "no")"

auto_label="Automatic (DHCP)"
cloudflare_label="Cloudflare (1.1.1.1, 1.0.0.1)"
google_label="Google (8.8.8.8, 8.8.4.4)"
quad9_label="Quad9 (9.9.9.9, 149.112.112.112)"
opendns_label="OpenDNS (208.67.222.222, 208.67.220.220)"

if [[ "${current_ignore_auto}" != "yes" || -z "${current_dns}" ]]; then
    auto_label="${auto_label} *"
elif [[ "${current_dns}" == "1.1.1.1,1.0.0.1" ]]; then
    cloudflare_label="${cloudflare_label} *"
elif [[ "${current_dns}" == "8.8.8.8,8.8.4.4" ]]; then
    google_label="${google_label} *"
elif [[ "${current_dns}" == "9.9.9.9,149.112.112.112" ]]; then
    quad9_label="${quad9_label} *"
elif [[ "${current_dns}" == "208.67.222.222,208.67.220.220" ]]; then
    opendns_label="${opendns_label} *"
fi

choice="$(printf "%s\n%s\n%s\n%s\n%s\n" \
    "${auto_label}" \
    "${cloudflare_label}" \
    "${google_label}" \
    "${quad9_label}" \
    "${opendns_label}" | fuzzel --dmenu --config "${FUZZEL_CONFIG}" --prompt "DNS> ")"

if [[ -z "${choice}" ]]; then
    exit 0
fi

choice="${choice% \*}"

case "${choice}" in
    "Automatic (DHCP)")
        nmcli connection modify "${active_connection}" ipv4.ignore-auto-dns no ipv4.dns ""
        ;;
    "Cloudflare (1.1.1.1, 1.0.0.1)")
        nmcli connection modify "${active_connection}" ipv4.ignore-auto-dns yes ipv4.dns "1.1.1.1,1.0.0.1"
        ;;
    "Google (8.8.8.8, 8.8.4.4)")
        nmcli connection modify "${active_connection}" ipv4.ignore-auto-dns yes ipv4.dns "8.8.8.8,8.8.4.4"
        ;;
    "Quad9 (9.9.9.9, 149.112.112.112)")
        nmcli connection modify "${active_connection}" ipv4.ignore-auto-dns yes ipv4.dns "9.9.9.9,149.112.112.112"
        ;;
    "OpenDNS (208.67.222.222, 208.67.220.220)")
        nmcli connection modify "${active_connection}" ipv4.ignore-auto-dns yes ipv4.dns "208.67.222.222,208.67.220.220"
        ;;
    *)
        exit 0
        ;;
esac

if nmcli connection up "${active_connection}" >/dev/null 2>&1; then
    notify "Applied DNS for ${active_connection}"
else
    notify "Failed to reactivate ${active_connection}"
    exit 1
fi