#!/usr/bin/env bash
set -euo pipefail

# idle-inhibit.sh - toggle systemd idle inhibition for "Settings" actions
# Usage: idle-inhibit.sh enable|disable|toggle|status

PID_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/niri"
PID_FILE="$PID_DIR/idle-inhibit.pid"
INHIBIT_CMD=(systemd-inhibit --what=idle --who="niri-settings" --why="Settings open" sleep infinity)

ensure_pid_dir() {
    mkdir -p "$PID_DIR"
}

is_running() {
    [[ -f "$PID_FILE" ]] || return 1
    local pid
    pid=$(<"$PID_FILE")
    kill -0 "$pid" >/dev/null 2>&1
}

enable() {
    if is_running; then
        echo "Idle inhibit already active (pid=$(<"$PID_FILE"))."
        return 0
    fi

    command -v systemd-inhibit >/dev/null 2>&1 || { echo "systemd-inhibit not found." >&2; return 2; }

    ensure_pid_dir
    nohup "${INHIBIT_CMD[@]}" >/dev/null 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_FILE"
    echo "Enabled idle inhibit (pid=$pid)."
    command -v notify-send >/dev/null 2>&1 && notify-send "Idle inhibit enabled" "Settings will prevent idle actions until disabled."
}

disable() {
    if ! [[ -f "$PID_FILE" ]]; then
        echo "Idle inhibit not active."
        return 0
    fi
    local pid
    pid=$(<"$PID_FILE")
    if kill "$pid" >/dev/null 2>&1; then
        rm -f "$PID_FILE"
        echo "Disabled idle inhibit (killed pid $pid)."
        command -v notify-send >/dev/null 2>&1 && notify-send "Idle inhibit disabled" "Settings idle inhibition stopped."
        return 0
    else
        echo "Failed to kill process $pid. Cleaning pidfile." >&2
        rm -f "$PID_FILE"
        return 2
    fi
}

status() {
    if is_running; then
        echo "enabled (pid=$(<"$PID_FILE"))."
        return 0
    else
        echo "disabled."
        return 1
    fi
}

toggle() {
    if is_running; then
        disable
    else
        enable
    fi
}

case "${1:-}" in
    enable)
        enable
        ;;
    disable)
        disable
        ;;
    toggle)
        toggle
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 enable|disable|toggle|status" >&2
        exit 2
        ;;
esac
