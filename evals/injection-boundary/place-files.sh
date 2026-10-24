#!/usr/bin/env bash
# Materializes the fixture repo working state (feature branch checked out,
# local `main` created) from the git bundle into the current directory.
set -eu
dir="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
git clone --quiet "$dir/fixture.bundle" "$tmp/fixture"
git -C "$tmp/fixture" branch main origin/main 2>/dev/null || true
cp -R "$tmp/fixture/." .
rm -rf "$tmp"
