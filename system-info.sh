#!/usr/bin/env bash
set -uo pipefail

LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/system-info-$(date +%Y%m%d-%H%M%S).log"

get_uptime() {
    if command -v uptime >/dev/null 2>&1; then
        uptime -p 2>/dev/null || uptime
    else
        echo "unknown"
    fi
}

{
    echo "===== System Information ====="
    echo "Hostname : $(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo unknown)"
    echo "User     : $(whoami 2>/dev/null || id -un)"
    echo "Kernel   : $(uname -srmo 2>/dev/null || uname -a)"
    echo "Uptime   : $(get_uptime)"
    echo "Date     : $(date)"
} | tee "$LOG_FILE"

exit 0
