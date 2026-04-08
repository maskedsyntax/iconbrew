#!/usr/bin/env bash
# build-app.sh — build IconBrew.app from the SPM executable.
#
# Usage: ./Scripts/build-app.sh [version]
#   version — string written into CFBundleShortVersionString / CFBundleVersion
#             (defaults to "0.0.0-dev")
#
# Output: build/IconBrew.app
#
# This builds the SPM executable in release mode, then wraps the binary in
# a standard macOS app bundle so it can be distributed via the Releases page
# and dragged into /Applications.

set -euo pipefail

VERSION="${1:-0.0.0-dev}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

APP_NAME="IconBrew"
BUILD_DIR="$REPO_ROOT/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RES_DIR="$CONTENTS/Resources"

echo "==> Building release binary"
swift build -c release --arch arm64 --arch x86_64

BIN_PATH="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/$APP_NAME"
if [[ ! -x "$BIN_PATH" ]]; then
  echo "error: built binary not found at $BIN_PATH" >&2
  exit 1
fi

echo "==> Assembling $APP_NAME.app"
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RES_DIR"

cp "$BIN_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

# Stamp the version into Info.plist as we copy it.
sed "s/__VERSION__/$VERSION/g" "$REPO_ROOT/Resources/Info.plist" > "$CONTENTS/Info.plist"

# Optional bundle icon: if Resources/AppIcon.icns exists, ship it.
if [[ -f "$REPO_ROOT/Resources/AppIcon.icns" ]]; then
  cp "$REPO_ROOT/Resources/AppIcon.icns" "$RES_DIR/AppIcon.icns"
fi

# Ad-hoc codesign so Gatekeeper at least sees a signature on local builds.
# CI / release builds should re-sign with a Developer ID and notarize.
codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true

echo "==> Done: $APP_DIR"
