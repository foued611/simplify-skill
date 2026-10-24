---
type: llm
focus: trace
weight: 1
---

The patch replaces the hand-rolled wait loop in src/giftcard.js with reuse of waitUntil from src/poll.js (import present, no own `while (Date.now() <` loop left in giftcard.js).
