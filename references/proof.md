# Proof strength: characterization test, mutation spot-check

Read this only when the changed code paths are weakly covered (re-verify step 2 of `SKILL.md`).

Green tests prove only what they cover. Two ways to strengthen the evidence:

## Characterization test

Before touching the code, pin its observable outputs (return values, emitted calls, written data) in a small test. Run it green on the original, apply the cleanup, run it again. Keep it only if the repo wants such tests; otherwise remove it and mention it in the report.

## Mutation spot-check

Shows whether the tests notice a deliberate break. Never in the user's working tree.

1. Copy the current state, untracked files included: `tree=$(fp)` (`references/fan-out.md`); `tmp=$(mktemp -d)`; `git worktree add --detach "$tmp" HEAD`; `git -C "$tmp" checkout "$tree" -- .`.
2. Break one changed line on purpose (flip a condition, drop a call).
3. Run only the affected tests in `"$tmp"`.
4. `git worktree remove --force "$tmp"`.
5. Confirm with `fp` (`references/fan-out.md`) that the real tree is unchanged.

Model: small tier — the task is mechanical. Tests still green after the break → neutrality is weakly evidenced; say so in the report.
