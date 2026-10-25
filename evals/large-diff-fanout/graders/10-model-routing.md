---
type: llm
focus: trace
weight: 1
---

The trace shows a model chosen per task before launch, following the routing table in SKILL.md: lens reviewers are launched with an explicit model (mid for Reuse/Simplification/Efficiency, small for Altitude, or top for Efficiency when the diff touches polling), reviewers receive only their lens prompt (not the whole SKILL.md), apply/decline stays with the orchestrator, and report.md has a Models line (tiers per task, or "inherited" when the environment offers no per-task model choice).
