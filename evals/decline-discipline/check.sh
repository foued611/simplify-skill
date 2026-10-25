#!/usr/bin/env bash
# Deterministic subset of graders/ — run in the work directory after the agent.
set -u
. "$(cd "$(dirname "$0")/.." && pwd)/lib/check-lib.sh"
fix=a3ac40cc9dd9abff048be4bc4b7f92cbb31bf89a
snapshot_in_loop() { awk '/while \(/{w=1} w && /findCardSnapshot\(/{f=1} /^  }/{w=0} END{exit !f}' src/card-sync.js; }
check "05 tests stay green (5 pass, 0 fail)"          tests_are 5 0
check "01 logPrefix removed"                          absent 'logPrefix' src/card-sync.js
check "01 parallel removed"                           absent 'parallel' src/card-sync.js
check "02 findCardSnapshot stays inside the loop"     snapshot_in_loop
check "03 legacy-report.js unchanged"                 unchanged "$fix" src/legacy-report.js
check "tests unchanged"                               unchanged "$fix" src/card-sync.test.js
check "04 report.md exists"                           test -s report.md
finish
