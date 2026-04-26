#!/usr/bin/env bash
set -euo pipefail

# idle-daemon.sh - swayidle manager for Niri
# Locks screen after LOCK_TIMEOUT, suspends after SUSPEND_TIMEOUT.

# -- Config (override via env) -----------------------------------------------
LOCK_TIMEOUT="${LOCK_TIMEOUT:-300}"
SUSPEND_TIMEOUT="${SUSPEND_TIMEOUT:-900}"
LOCK_SCRIPT="$HOME/.config/niri/scripts/lock-screen.sh"
LOG_TAG="idle-daemon"

# -- Helpers -----------------------------------------------------------------
log()  { logger -t "$LOG_TAG" -- "$*"; echo "[idle-daemon] $*"; }
die()  { log "ERROR: $*" >&2; exit 1; }

# -- Preflight checks --------------------------------------------------------
command -v swayidle >/dev/null 2>&1 || die "swayidle is not installed."
[[ -x "$LOCK_SCRIPT" ]]            || die "Lock script not found or not executable: $LOCK_SCRIPT"

[[ "$LOCK_TIMEOUT" -gt 0 ]]        || die "LOCK_TIMEOUT must be a positive integer."
[[ "$SUSPEND_TIMEOUT" -gt "$LOCK_TIMEOUT" ]] \
                                   || die "SUSPEND_TIMEOUT ($SUSPEND_TIMEOUT) must be greater than LOCK_TIMEOUT ($LOCK_TIMEOUT)."

# -- Kill any existing instance ----------------------------------------------
if pkill -x swayidle 2>/dev/null; then
    log "Killed existing swayidle instance."
fi

log "Starting: lock=${LOCK_TIMEOUT}s, suspend=${SUSPEND_TIMEOUT}s"

LOCK_CMD="$LOCK_SCRIPT --daemonize"
SUSPEND_CMD="$LOCK_SCRIPT --daemonize && systemctl suspend"

# -- Launch ------------------------------------------------------------------
exec swayidle -w \
    timeout "$LOCK_TIMEOUT"    "$LOCK_CMD" \
    timeout "$SUSPEND_TIMEOUT" "$SUSPEND_CMD" \
    before-sleep               "$LOCK_CMD"
