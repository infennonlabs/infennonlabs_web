#!/usr/bin/env bash
# Try the Study Plan in Chrome with the games built from this machine.
#
#   tool/study_plan_local.sh build [game-id ...]
#                                    builds the ready Study Plan games, or just the ids given
#                                    (a minute or so each)
#   tool/study_plan_local.sh serve   serves them on http://localhost:8090 (leave running)
#   tool/study_plan_local.sh home    runs the home in Chrome, embedding those games
#
# The game list comes from .github/learning/study_plan.json in the hub. Games are built from their
# own folders next to this one, from whatever
# branch each has checked out. Output goes to build/study_games/<slug>/.
set -euo pipefail

HOME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$(cd "$HOME_DIR/.." && pwd)"
OUT="$HOME_DIR/build/study_games"
PORT="${STUDY_PLAN_PORT:-8090}"

HUB_DIR="$DOCS_DIR/.workspace-copilot"

# "app-folder:slug" lines for the games to build: the ids given after `build`, or
# every game the Study Plan data file marks ready.
game_lines() {
  python3 - "$HUB_DIR" "$@" <<'PY'
import json, sys
hub, wanted = sys.argv[1], set(sys.argv[2:])
data = json.load(open(f"{hub}/.github/learning/study_plan.json"))["games"]
games = {g["id"]: g for g in json.load(open(f"{hub}/.github/learning/games.json"))}
for gid, g in data.items():
    if (gid in wanted) if wanted else g.get("ready"):
        print(f"{games[gid]['localPath']}:{games[gid]['slug']}")
PY
}

case "${1:-}" in
  build)
    shift
    mkdir -p "$OUT"
    built=0
    while IFS= read -r entry; do
      app="${entry%%:*}"
      slug="${entry##*:}"
      echo "== building $app -> /$slug/"
      (cd "$DOCS_DIR/$app" && flutter build web --release --base-href "/$slug/" --output "$OUT/$slug")
      built=$((built + 1))
    done < <(game_lines "$@")
    echo "Built $built games into $OUT"
    ;;
  serve)
    echo "Serving $OUT on http://localhost:$PORT (Ctrl-C to stop)"
    exec python3 -m http.server "$PORT" --directory "$OUT"
    ;;
  home)
    cd "$HOME_DIR"
    exec flutter run -d chrome --debug \
      --dart-define=STUDY_PLAN_GAME_BASE_URL="http://localhost:$PORT"
    ;;
  *)
    echo "Usage: $0 build|serve|home" >&2
    exit 2
    ;;
esac
