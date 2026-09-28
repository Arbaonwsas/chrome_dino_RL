#!/usr/bin/env bash
# Fetch the chromedriver that matches the locally installed Google Chrome into
# ./drivers/chromedriver, where utils/game.py picks it up automatically.
#
# Selenium Manager (built into Selenium >= 4.6) normally downloads the matching
# driver by itself. That needs access to storage.googleapis.com, which is
# blocked or filtered on some networks; there, Selenium Manager fails with
# "error decoding response body for url (...)". Running this script once works
# around it, and the driver is then reused on every later run.
#
# Re-run it after Chrome updates, otherwise the session fails with
# "This version of ChromeDriver only supports Chrome version NNN".
#
# Environment overrides:
#   CHROME_BIN   Chrome executable to read the version from (default: google-chrome)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="$REPO_DIR/drivers"
CHROME_BIN="${CHROME_BIN:-google-chrome}"

command -v "$CHROME_BIN" >/dev/null 2>&1 || {
    echo "error: $CHROME_BIN not found; set CHROME_BIN to your Chrome binary" >&2
    exit 1
}

VERSION="$("$CHROME_BIN" --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' || true)"
[ -n "$VERSION" ] || {
    echo "error: could not parse a version out of '$("$CHROME_BIN" --version)'" >&2
    exit 1
}

URL="https://storage.googleapis.com/chrome-for-testing-public/${VERSION}/linux64/chromedriver-linux64.zip"
echo "Chrome ${VERSION}"
echo "fetching ${URL}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fL --retry 3 -o "$TMP_DIR/chromedriver.zip" "$URL"
mkdir -p "$DEST_DIR"
unzip -o -j "$TMP_DIR/chromedriver.zip" chromedriver-linux64/chromedriver -d "$DEST_DIR" >/dev/null
chmod +x "$DEST_DIR/chromedriver"

echo "installed:"
"$DEST_DIR/chromedriver" --version
