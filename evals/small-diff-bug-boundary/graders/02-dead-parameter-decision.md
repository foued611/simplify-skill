---
type: llm
focus: trace
weight: 1
---

The patch removes the dead channel parameter of due() including the 'off' branch (no caller passes it, no test touches it — removal is behavior-preserving), and report.md lists it as applied.
