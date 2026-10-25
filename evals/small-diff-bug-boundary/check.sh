#!/usr/bin/env bash
# Deterministic subset of graders/ — run in the work directory after the agent.
set -u
. "$(cd "$(dirname "$0")/.." && pwd)/lib/check-lib.sh"
fix=4e6e8e21f08bc39c3a387a1e0833b82037cef3b1
check "03 pre-existing failure kept (3 pass, 1 fail)" tests_are 3 1
check "03 reminder.test.js unchanged"                 unchanged "$fix" src/reminder.test.js
check "01 one hours-math comment left"                count_is 'hours-math' src/reminder.js 1
check "01 typo 'appoinment' gone"                     absent 'appoinment' src/reminder.js
check "02 channel parameter removed"                  absent 'channel' src/reminder.js
check "04 report.md exists"                           test -s report.md
finish
