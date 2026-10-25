---
type: llm
focus: trace
weight: 1
---

The patch replaces the hand-rolled Math.min(Math.max(...)) in discountCents with clamp from src/math.js and removes the dead roundMode parameter including the ceil branch.
