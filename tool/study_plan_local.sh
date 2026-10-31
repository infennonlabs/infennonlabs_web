#!/usr/bin/env bash
# Try the Study Plan in Chrome with the games built from this machine.
#
#   tool/study_plan_local.sh build   builds the eight Study Plan games (a few minutes)
#   tool/study_plan_local.sh serve   serves them on http://localhost:8090 (leave running)
#   tool/study_plan_local.sh home    runs the home in Chrome, embedding those games
#
# The games are built from their own folders next to this one, from whatever
# branch each has checked out. Output goes to build/study_games/<slug>/.
set -euo pipefail

HOME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$(cd "$HOME_DIR/.." && pwd)"
OUT="$HOME_DIR/build/study_games"
PORT="${STUDY_PLAN_PORT:-8090}"

# app folder : slug the home embeds it from
GAMES=(
  "pumpkin_carver:pumpkin-carving"
  "piano_synth_demo:piano"
  "cooking_kids:cooking"
  "paint_by_number:coloring"
  "anatomy_kids:anatomy"
  "farm_kids:farming"
  "comic_kids:comicbook"
  "arcade_lab:arcade"
)

case "${1:-}" in
  build)
    mkdir -p "$OUT"
    for entry in "${GAMES[@]}"; do
      app="${entry%%:*}"
      slug="${entry##*:}"
      echo "== building $app -> /$slug/"
      (cd "$DOCS_DIR/$app" && flutter build web --release --base-href "/$slug/" --output "$OUT/$slug")
    done
    echo "Built ${#GAMES[@]} games into $OUT"
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
