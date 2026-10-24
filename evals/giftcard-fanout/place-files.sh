#!/usr/bin/env bash
# Materialisiert den Fixture-Repo-Arbeitsstand (Feature-Branch ausgecheckt)
# aus dem Git-Bundle im aktuellen Verzeichnis.
set -eu
dir="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
git clone --quiet "$dir/fixture.bundle" "$tmp/fixture"
cp -R "$tmp/fixture/." .
rm -rf "$tmp"
