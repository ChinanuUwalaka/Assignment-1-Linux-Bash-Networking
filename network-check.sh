#!/usr/bin/env bash
set -uo pipefail

LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/network-check-$(date +%Y%m%d-%H%M%S).log"

usage() {
    echo "Usage: $0 <host> [port]" >&2
}

if [[ $# -lt 1 ]]; then
    usage
    exit 2
fi

HOST="$1"
PORT="${2:-80}"

if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "Error: port must be a whole number" >&2
    exit 2
fi

if (( PORT < 1 || PORT > 65535 )); then
    echo "Error: port must be between 1 and 65535" >&2
    exit 2
fi

{
    echo "===== Network Check ====="
    echo "Host : $HOST"
    echo "Port : $PORT"
} | tee "$LOG_FILE"

PING_OK=1
if command -v ping >/dev/null 2>&1; then
    if ping -c 1 -W 2 "$HOST" >/dev/null 2>&1; then
        PING_OK=0
    fi
fi

if [[ $PING_OK -eq 0 ]]; then
    echo "Ping   : reachable" | tee -a "$LOG_FILE"
else
    echo "Ping   : unreachable or blocked" | tee -a "$LOG_FILE"
fi

PORT_OK=1
if timeout 2 bash -c "echo > /dev/tcp/${HOST}/${PORT}" >/dev/null 2>&1; then
    PORT_OK=0
fi

if [[ $PORT_OK -eq 0 ]]; then
    echo "Port   : open" | tee -a "$LOG_FILE"
else
    echo "Port   : closed or filtered" | tee -a "$LOG_FILE"
fi

if [[ $PING_OK -eq 0 || $PORT_OK -eq 0 ]]; then
    echo "RESULT : reachable" | tee -a "$LOG_FILE"
    exit 0
else
    echo "RESULT : unreachable" | tee -a "$LOG_FILE"
    exit 1
fi
