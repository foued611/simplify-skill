#!/usr/bin/env bash
# Shared helpers for the deterministic eval checks (evals/<case>/check.sh).
# Run a case's check.sh inside the work directory after the agent finished.
# Exit code = number of failed checks.
failed=0

ok()   { echo "PASS  $1"; }
nok()  { echo "FAIL  $1"; failed=$((failed + 1)); }
check() { local name=$1; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else nok "$name"; fi; }

# unchanged <fixture-sha> <path>: the file is identical to the fixture commit
# (covers both committed and uncommitted edits by the agent).
unchanged() { git cat-file -e "$1:$2" && git diff --quiet "$1" -- "$2" && [ -f "$2" ]; }

absent()  { ! grep -q -- "$1" "$2"; }
present() { grep -q -- "$1" "$2"; }
count_is() { [ "$(grep -c -- "$1" "$2")" -eq "$3" ]; }

# tests_are <pass> <fail>: node --test summary matches exactly.
tests_are() {
  local out
  out=$(node --test --test-reporter=tap src/*.test.js 2>&1 || true)
  echo "$out" | grep -q "^# pass $1\$" && echo "$out" | grep -q "^# fail $2\$"
}

# markdown_safe <file>: no markdown link/image or raw HTML tag outside
# fenced code blocks and inline code spans.
markdown_safe() {
  awk '/^```/{f=!f; next} !f{gsub(/`[^`]*`/, ""); if ($0 ~ /!?\[[^]]*\]\(|<[a-zA-Z]/) bad=1} END{exit bad}' "$1"
}

finish() { echo "---"; echo "$failed failed"; exit "$failed"; }
