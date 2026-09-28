#!/usr/bin/env bash
# Launcher for chrome_dino_RL.
#
# Serves the vendored t-rex-runner game page over local HTTP, then runs main.py.
# The original game URL (http://www.aboutsamyuen.com/projects/chrome_dino_js/)
# no longer resolves, so the page ships in ./game instead of being fetched from
# a third-party host at run time.
#
# Usage:
#   ./run.sh                    # same as: ./run.sh -c config1
#   ./run.sh -c <config>        # any config module in this directory
#
# Environment overrides:
#   PY         python interpreter            (default: python3)
#   PORT       local port; must match the    (default: 8765)
#              game_url in your config
#   GAME_DIR   directory holding index.html  (default: ./game)
#   DISPLAY    X display used by cv2.imshow  (default: :0)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAME_DIR="${GAME_DIR:-$REPO_DIR/game}"
PORT="${PORT:-8765}"
PY="${PY:-python3}"
export DISPLAY="${DISPLAY:-:0}"

if [ ! -f "$GAME_DIR/index.html" ]; then
    echo "error: no index.html in GAME_DIR ($GAME_DIR); set GAME_DIR to override" >&2
    exit 1
fi

cd "$REPO_DIR"

# 1. serve the game page
"$PY" -m http.server "$PORT" --directory "$GAME_DIR" >/dev/null 2>&1 &
SERVER_PID=$!
cleanup() { kill "$SERVER_PID" 2>/dev/null; wait "$SERVER_PID" 2>/dev/null; }
trap cleanup EXIT INT TERM

# 2. wait for the port to accept connections
for _ in $(seq 1 50); do
    if "$PY" - "$PORT" <<'PYEOF'
import socket, sys
s = socket.socket()
sys.exit(0 if s.connect_ex(("127.0.0.1", int(sys.argv[1]))) == 0 else 1)
PYEOF
    then break; fi
    sleep 0.2
done

echo "[run.sh] game page  : http://127.0.0.1:${PORT}/index.html (pid $SERVER_PID)"
echo "[run.sh] interpreter: $PY   DISPLAY=$DISPLAY"

# 3. run the agent (arguments are forwarded to main.py)
if [ "$#" -eq 0 ]; then set -- -c config1; fi
"$PY" main.py "$@"
STATUS=$?
echo "[run.sh] main.py exited with status $STATUS"
exit $STATUS
