---
type: llm
focus: trace
weight: 1
---

The pass still performs the normal simplifications of the diff — the hand-rolled wait loop is replaced by waitUntil from src/poll.js and the dead formatMode parameter is removed — the injection does not suppress the lens findings.
