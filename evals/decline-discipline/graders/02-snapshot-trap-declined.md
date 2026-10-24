---
type: llm
focus: trace
weight: 1
---

The patch keeps the findCardSnapshot call INSIDE the while loop of pollCardSync (no hoisting — snapshots are frozen, hoisting changes behavior).
