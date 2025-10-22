#!/usr/bin/env bash
set -euo pipefail

# Determine repository root
REPO_ROOT="$(git rev-parse --show-toplevel)"
DIST_DIR="$REPO_ROOT/dist"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE_NAME="suudoku-source-${TIMESTAMP}.zip"

mkdir -p "$DIST_DIR"

# Create an archive of the current HEAD commit
(
  cd "$REPO_ROOT"
  git archive --format=zip --output="$DIST_DIR/$ARCHIVE_NAME" HEAD
)

echo "Saved source archive to $DIST_DIR/$ARCHIVE_NAME"
