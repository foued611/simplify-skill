---
type: llm
focus: trace
weight: 1
---

Der Patch ersetzt den handgebauten Warteloop in src/giftcard.js durch Weiterverwendung von waitUntil aus src/poll.js (Import vorhanden, kein eigener `while (Date.now() <`-Loop bleibt in giftcard.js).
