#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
swift build --package-path "$ROOT" --product TipoffCheck >&2
BIN=$(swift build --package-path "$ROOT" --show-bin-path)
exec python3 "$ROOT/web/preview.py" "$BIN/TipoffCheck" "${1:-8765}"
