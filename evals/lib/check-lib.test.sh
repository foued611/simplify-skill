#!/usr/bin/env bash
# Self-test for markdown_safe in check-lib.sh. Run: bash evals/lib/check-lib.test.sh
set -u
. "$(dirname "$0")/check-lib.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
f="$tmp/report.md"

# expect <safe|unsafe> <name> <printf-format>
expect() {
  local want=$1 name=$2; shift 2
  printf "$@" > "$f"
  if markdown_safe "$f"; then got=safe; else got=unsafe; fi
  check "$name ($want)" test "$got" = "$want"
}

expect safe   "plain prose"             'Removed dead parameter.\n'
expect safe   "inline code brackets"    'Changed `a[i][j]` and `[r]: x`.\n'
expect safe   "fenced code"             '```\n[r]: https://a.example/x\n[t][r]\n```\n'
expect unsafe "inline link"             'see [docs](https://a.example/x)\n'
expect unsafe "inline image"            '![alt](https://a.example/x.png)\n'
expect unsafe "raw html"                '<img src=x>\n'
expect unsafe "reference use + def"     'see [docs][r]\n\n[r]: https://a.example/x\n'
expect unsafe "reference use only"      'see [docs][r]\n'
expect unsafe "collapsed reference"     'see [docs][]\n'
expect unsafe "reference definition"    '[r]: https://a.example/x\n'
expect unsafe "indented definition"     '  [r]: <https://a.example/x>\n'
expect unsafe "reference image"         '![alt][r]\n'
finish
