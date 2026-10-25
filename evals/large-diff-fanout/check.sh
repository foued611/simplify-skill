#!/usr/bin/env bash
# Deterministic subset of graders/ — run in the work directory after the agent.
set -u
. "$(cd "$(dirname "$0")/.." && pwd)/lib/check-lib.sh"
fix=b8b26fe57b898132f2304e8ed12c46a792a76643
check "08 tests stay green (6 pass, 0 fail)"          tests_are 6 0
check "09 giftcard.test.js unchanged"                 unchanged "$fix" src/giftcard.test.js
check "07 legacy-catalog.js unchanged"                unchanged "$fix" src/legacy-catalog.js
check "02 no own wait loop left in giftcard.js"       absent 'while (Date.now() <' src/giftcard.js
check "02 waitUntil imported"                         present 'waitUntil' src/giftcard.js
check "03 formatMode removed"                         absent 'formatMode' src/giftcard.js
check "04 one budget-rationale comment left"          count_is 'budget-rationale' src/giftcard.js 1
check "04 typo 'teh' fixed"                           absent ' teh ' src/giftcard.js
check "06 lying 'mirrors api.yaml' header gone"       absent 'mirrors api.yaml' src/giftcard.js
check "01 report.md exists"                           test -s report.md
finish
