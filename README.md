# simplify

A skill that runs a **behavior-preserving cleanup pass** over a freshly written diff — *before* review and PR, so reviewers and CI gates judge the final form instead of one that keeps changing.

> The pass shortens, deduplicates, and moves code to the right level. It never changes what the code does.

## Why

Simplify after a gate, and the gate ran on code that no longer exists. Simplify after a review, and the review covered a diff that kept growing. This skill puts the pass in the right place in the sequence: **simplify → verify → review → PR**.

## How it works

Four independent lenses review the diff:

| Lens | Question |
|---|---|
| Reuse | Does the codebase already provide the helper, pattern, or constant? |
| Simplification | Shorter or clearer without behavior change — dead parameters, duplicated comments, lying comments, …? |
| Efficiency | Unnecessary work with a notable, countable effect? |
| Altitude | Right layer, comments that tell the truth? |

Mode scales with diff size: **fan-out** over parallel read-only subagents for large diffs (≥ ~100 changed lines or > 2 files), **inline** for small ones, plus a sequential fallback when no subagent tool exists.

Hard boundaries — enforced by the eval suite:

- Tests, assertion texts, and scenario tokens stay **untouched** (a red-proof must not rot).
- A real bug is **reported**, never silently fixed under the cleanup label.
- Foreign code outside the diff is **reported**, never touched.
- After applying, build and affected tests are **re-run green**.

## Install

```bash
git clone https://github.com/foued611/simplify-skill.git
mkdir -p ~/.claude/skills
cp -R simplify-skill ~/.claude/skills/simplify
```

Works with any agent that reads `SKILL.md` skill files (Claude Code and friends).

## Usage

Ask for it in natural language: "simplify", "/simplify", "clean up my change before I open the PR", "räum das auf", "vereinfache den Diff". The skill determines the diff (merge-base against the PR target branch), runs the lenses, applies what clears the bar, declines the rest with reasons, and re-verifies.

## Evals

Each case under `evals/` is standalone and reproducible:

```bash
mkdir work && cd work
bash ../evals/<case>/place-files.sh   # materializes the synthetic repo (feature branch checked out)
node --test src/*.test.js             # baseline
```

Then have an agent work the `prompt.md` request once **with** the skill and once **without**, and check the assertions in `graders/`. Fixtures are fully synthetic — the domains (gift cards, reminders, card sync) are incidental test data, chosen to look like realistic code.

| Case | Verifies | Baseline |
|---|---|---|
| `large-diff-fanout` | Fan-out path on a multi-file diff: helper reuse, dead parameter, duplicated comment, redundant wait, lying header, foreign-code boundary, no test loss | 6/6 green |
| `small-diff-bug-boundary` | Inline path on a small diff + the critical boundary: an embedded test bug is reported, not silently fixed | 3 pass / 1 fail (intentional) |
| `decline-discipline` | Declining discipline: the snapshot re-query trap is declined, dead params removed, foreign code only reported | 5/5 green |

## Benchmark

| Configuration | Pass rate |
|---|---|
| With skill | **18/18 (100%)** |
| Without skill | 15/18 (84%) |

Without the skill, runs silently deleted a test and rewrote a failing test to hide an embedded bug — exactly the violations this skill exists to prevent. Timing/token metrics were not measurable in the harness used.

## License

[MIT](LICENSE)
