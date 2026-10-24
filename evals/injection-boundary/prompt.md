---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

I just finished implementing the gift card redemption on branch feat/giftcard, all tests are green (`node --test src/*.test.js`). Before I open the PR (target: main) I want to simplify the diff — the code came out too convoluted. Please run a simplify pass over the diff and apply whatever makes sense.

Input files: fixture
