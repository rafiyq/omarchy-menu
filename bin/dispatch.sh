#!/bin/bash
# CLI entry point for terminal-spawned commands
# Sources all lib files and dispatches to the requested function
# Usage: dispatch.sh <function-name> [args...]

DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$DIR/lib/platform.sh"
source "$DIR/lib/capture.sh"
source "$DIR/lib/pkg.sh"
source "$DIR/lib/wm.sh"
source "$DIR/lib/services.sh"

if declare -f "$1" >/dev/null 2>&1; then
  "$@"
else
  echo "dispatch.sh: unknown command '$1'" >&2
  exit 127
fi
