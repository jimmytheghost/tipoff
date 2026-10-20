#!/bin/sh
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
OUTPUT_DIR=${1:-"$PROJECT_ROOT/dist"}
APP_DIR="$OUTPUT_DIR/Tipoff.app"
swift build --package-path "$PROJECT_ROOT" -c release --product Tipoff
BIN_DIR=$(swift build --package-path "$PROJECT_ROOT" -c release --show-bin-path)
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BIN_DIR/Tipoff" "$APP_DIR/Contents/MacOS/Tipoff"
cp "$PROJECT_ROOT/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
if [ ! -f "$PROJECT_ROOT/Resources/Tipoff.icns" ]; then
    swift "$SCRIPT_DIR/generate-icon.swift" "$PROJECT_ROOT/Resources"
    iconutil -c icns "$PROJECT_ROOT/Resources/Tipoff.iconset" -o "$PROJECT_ROOT/Resources/Tipoff.icns"
fi
cp "$PROJECT_ROOT/Resources/Tipoff.icns" "$APP_DIR/Contents/Resources/Tipoff.icns"
chmod 755 "$APP_DIR/Contents/MacOS/Tipoff"
codesign --force --sign "${TIPOFF_SIGNING_IDENTITY:--}" "$APP_DIR"
codesign --verify --deep --strict "$APP_DIR"
printf 'Packaged %s\n' "$APP_DIR"
