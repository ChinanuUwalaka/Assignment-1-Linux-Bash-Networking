#!/usr/bin/env bash
set -uo pipefail

LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/disk-check-$(date +%Y%m%d-%H%M%S).log"

usage() {
    echo "Usage: $0 <threshold 1-100> [path]" >&2
}

if [[ $# -lt 1 ]]; then
    usage
    exit 2
fi

THRESHOLD="$1"
TARGET_PATH="${2:-/}"

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: threshold must be a whole number" >&2
    exit 2
fi

if (( THRESHOLD < 1 || THRESHOLD > 100 )); then
    echo "Error: threshold must be between 1 and 100" >&2
    exit 2
fi

if [[ ! -e "$TARGET_PATH" ]]; then
    echo "Error: path '$TARGET_PATH' does not exist" >&2
    exit 2
fi

USAGE_PCT="$(df -P "$TARGET_PATH" 2>/dev/null | awk 'NR==2 { gsub("%","",$5); print $5 }')"

if [[ -z "$USAGE_PCT" ]]; then
    echo "Error: could not determine disk usage for '$TARGET_PATH'" >&2
    exit 2
fi

{
    echo "===== Disk Check ====="
    echo "Path      : $TARGET_PATH"
    echo "Threshold : ${THRESHOLD}%"
    echo "Usage     : ${USAGE_PCT}%"
} | tee "$LOG_FILE"

if (( USAGE_PCT >= THRESHOLD )); then
    echo "WARNING: usage ${USAGE_PCT}% >= threshold ${THRESHOLD}%" | tee -a "$LOG_FILE"
    exit 1
fi

echo "OK: usage ${USAGE_PCT}% is below threshold ${THRESHOLD}%" | tee -a "$LOG_FILE"
exit 0
