# Assignment 1 — Linux / Bash / Networking / Git

A small toolkit of three standalone Bash scripts, each independently
executable, that report on the local system, check disk usage against a
threshold, and check basic network reachability of a host/port.

## Files

- `system-info.sh` — prints hostname, current user, kernel info, and uptime.
- `disk-check.sh` — validates a usage-percentage threshold (1–100) and an
  optional path (default `/`), then reports whether current disk usage is
  under that threshold.
- `network-check.sh` — validates a host and optional port (default `80`),
  then reports whether the host/port is reachable.
- All three scripts append a timestamped log entry under `logs/`.
