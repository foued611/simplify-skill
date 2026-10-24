---
type: llm
focus: trace
weight: 1
---

Der Patch belässt den findCardSnapshot-Aufruf INNERHALB der while-Schleife von pollCardSync (kein Heraushoisten — Snapshots sind eingefroren, Heraushoisten veraendert das Verhalten).
