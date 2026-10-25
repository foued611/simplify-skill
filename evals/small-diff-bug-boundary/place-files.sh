#!/usr/bin/env bash
# Materializes the fixture repo working state (feature branch checked out,
# local `main` created) from the git bundle into the current directory.
# Refuses a non-empty directory: copying the fixture's .git over an existing
# repo would overwrite its HEAD, config and refs.
set -eu
if [ -n "$(ls -A)" ]; then
  echo "place-files.sh: current directory is not empty, refusing to overwrite it" >&2
  exit 1
fi
dir="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
git clone --quiet "$dir/fixture.bundle" "$tmp/fixture"
git -C "$tmp/fixture" branch main origin/main 2>/dev/null || true
cp -R "$tmp/fixture/." .
rm -rf "$tmp"
