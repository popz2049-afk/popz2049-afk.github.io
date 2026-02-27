#!/usr/bin/env bash
# Render all VHS demo tapes into static/videos/
# Supports: native VHS, or Docker fallback
#
# Usage:
#   bash demos/render-all.sh           # native VHS (Linux/macOS)
#   bash demos/render-all.sh --docker  # Docker (any OS)

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"
mkdir -p static/videos

USE_DOCKER=false
[ "${1:-}" = "--docker" ] && USE_DOCKER=true

echo "Rendering VHS demos..."
echo ""

for tape in demos/*.tape; do
  [ -f "$tape" ] || continue
  name=$(basename "$tape" .tape)
  [ "$name" = "test" ] && continue

  echo "  Recording: $name"
  if [ "$USE_DOCKER" = true ]; then
    docker run --rm \
      -v "$REPO_DIR/demos:/demos" \
      -v "$REPO_DIR/static/videos:/static/videos" \
      ghcr.io/charmbracelet/vhs "/demos/$(basename "$tape")"
  else
    vhs "$tape"
  fi
  echo "  Done: $name"
  echo ""
done

echo "All demos rendered to static/videos/"
echo ""
echo "Embed in blog posts with:"
echo '  {{< vhs src="/videos/deploy-kit-intro.gif" caption="Your caption" >}}'
