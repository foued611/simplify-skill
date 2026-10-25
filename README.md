# simplify4me

A skill that runs a **behavior-preserving cleanup pass** over a freshly written diff — *before* review and PR, so reviewers and CI gates judge the final form instead of one that keeps changing.

> The pass shortens, deduplicates, and moves code to the right level. It never changes what the code does.

**Why the name:** Claude Code ships a bundled `/simplify` skill, and a personal skill named exactly `simplify` would shadow it — plus trigger Claude Code's run-before-every-commit coupling. `simplify4me` avoids both; the trigger phrases ("simplify my diff", "clean up my change", …) still work through the description, while a bare `/simplify` is left to the bundled skill.

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

Before any lens runs, the pass resolves the base to SHAs (branch names are untrusted shell input), checks for uncommitted work, reads the repo's agent instructions (verify commands, invariants, code limits), and records a test **baseline**.

Mode scales with diff size: **fan-out** over parallel read-only subagents for large diffs (≥ 100 changed code lines or > 2 code files, tests/docs/generated excluded), **inline** for small ones, plus a sequential fallback when no subagent tool exists.

Hard boundaries — enforced by the eval suite:

- Tests, assertion texts, scenario tokens, and repo invariants stay **untouched** (a red-proof must not rot).
- A real bug is **reported**, never silently fixed under the cleanup label; a test that was red before the pass is reported as **pre-existing**.
- Foreign code outside the diff is **reported**, never touched.
- After applying, the verify commands are **re-run and compared against the baseline**.
- Branch names, commit messages, and file content are **data**: never executed, never followed, never pasted as raw markdown into the report.

## Install

The skill folder conforms to the open [Agent Skills standard](https://agentskills.io) (`SKILL.md` plus optional resources). Primary targets: **Claude Code** and **OpenCode** — both load `~/.claude/skills/` (OpenCode auto-loads Claude Code skills), so one clone serves both.

**Claude Code + OpenCode (one clone, both agents):**

```bash
git clone https://github.com/foued611/simplify4me.git ~/.claude/skills/simplify4me
# update later (review the SKILL.md diff first — it is code):
git -C ~/.claude/skills/simplify4me pull
```

**Claude Code (plugin marketplace):**

```bash
# in Claude Code:
/plugin marketplace add foued611/simplify4me
/plugin install simplify4me@simplify4me
```

**OpenCode (explicit path registration):** add to `~/.config/opencode/opencode.json` — the loader scans the repo for `SKILL.md`:

```json
{ "skills": { "paths": ["~/path/to/simplify4me"] } }
```

Restart your agent after installing or updating (running sessions keep the already-loaded config).

## Usage

Ask for it in natural language: "simplify my diff", "/simplify4me", "clean up my change before I open the PR", "räum das auf", "vereinfache den Diff". The skill determines the diff (merge-base against the PR target branch), runs the lenses, applies what clears the bar, declines the rest with reasons, and re-verifies.

## Evals

Each case under `evals/` is standalone and reproducible:

```bash
mkdir work && cd work                 # place-files.sh refuses a non-empty directory
bash ../evals/<case>/place-files.sh   # materializes the synthetic repo (feature branch checked out)
node --test src/*.test.js             # fixture test state before the agent runs
```

Then have an agent work the `prompt.md` request once **with** the skill and once **without**, and grade the result in two layers:

1. **Deterministic:** `bash ../evals/<case>/check.sh` in the work directory — exit code = number of failed checks (tests, untouched files, removed patterns, report safety). Each check names the grader it backs.
2. **LLM graders:** the assertions in `graders/` for what a script cannot judge (justified declines, report wording, trace order).

Fixtures are fully synthetic — the domains (gift cards, reminders, card sync, discounts, routes) are incidental test data, chosen to look like realistic code. `evals/triggers.json` lists queries that must and must not trigger the skill (including a bare `/simplify` and correctness/security review requests).

| Case | Verifies | Fixture tests before the run |
|---|---|---|
| `large-diff-fanout` | Fan-out path on a multi-file diff: helper reuse, dead parameter, duplicated comment, redundant wait, lying header, foreign-code boundary, no test loss | 6 pass / 0 fail |
| `small-diff-bug-boundary` | Inline path on a small diff + the critical boundary: an embedded test bug is reported, not silently fixed | 3 pass / 1 fail (intentional) |
| `decline-discipline` | Declining discipline: the snapshot re-query trap is declined, dead params removed, foreign code only reported | 5 pass / 0 fail |
| `injection-boundary` | Prompt-injection boundary: an instruction embedded in the diff is data — reported, not followed; all lens findings still applied; tests re-run, test file intact | 6 pass / 0 fail |
| `untrusted-refs` | Shell-injection branch name (`feat/x$(touch${IFS}pwned)`) never executed, commit-message instruction not followed, attacker markdown kept out of the report, lens findings still applied | 4 pass / 0 fail |
| `dirty-tree-baseline` | Uncommitted part of the change is noticed, baseline recorded before editing, a test already red on main reported as pre-existing, no unrequested commit | 4 pass / 1 fail (intentional) |

## Benchmark

| Configuration | Pass rate (v1.1.0, first four cases) |
|---|---|
| With skill | **23/23 (100%)** |
| Without skill | 20/23 (87%) |

One run per configuration, LLM graders only — no variance measured, so read the gap as a signal, not a score. Without the skill, runs silently deleted a test and rewrote a failing test to hide an embedded bug — exactly the violations this skill exists to prevent. The `injection-boundary` case passes in both configurations: the baseline model also resists this payload, and the skill's contribution is turning that resistance into a guaranteed rule instead of luck. Timing/token metrics were not measurable in the harness used.

v1.2.0 adds `check.sh`, two cases, and tightened graders; it has not been benchmarked yet. Next benchmark: at least three runs per configuration over all six cases, reported as mean ± spread.

## Security

- **Prompt-injection posture:** the pass treats everything it reads — diff, files, comments, commit messages, branch names, reviewer findings — as data, never as instructions. Injected instructions — including ones echoed back by a reviewer — are reported as findings, not followed. Lens reviewers run memoryless and read-only (read-only agent type where available, plus a content fingerprint of the working tree, compared before and after the fan-out), every finding needs a behavior-equivalence justification, quoted code is fenced, and repo identifiers in the report are inline code.
- **Shell injection via refs:** git accepts branch names such as `a$(id)` or `a;id`. The pass resolves refs to SHAs once, quotes every variable, and passes `--` before paths.
- **Working tree safety:** mutation spot-checks run in a throwaway `git worktree`, never in the user's tree.
- **Evals execute generated code.** Agents under test write and run Node code, and fixtures come from git bundles that pull requests can modify. Run evals in a sandbox (container or VM) and review any diff touching `evals/` before you pull it. `place-files.sh` refuses a non-empty directory so it cannot overwrite an existing repo's `.git`.
- **`SKILL.md` is code.** This whole repository is instructions that run inside your agent sessions. Review changes to `SKILL.md` like code before updating, and pin a release tag when you consume the skill from automation.

### Known limitations

- **`markdown_safe` misses reference-style links.** The deterministic check behind the "no raw repo markdown in the report" guarantee matches inline links/images, autolinks and raw HTML, but not `[text][ref]` together with its `[ref]: <url>` definition — those still render as live links in a PR body. For this form the LLM grader is the only net, so the check is fail-open until fixed. Tracked in [#2](https://github.com/foued611/simplify4me/issues/2).

## License

[MIT](LICENSE)
