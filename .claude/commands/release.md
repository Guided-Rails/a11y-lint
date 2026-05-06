---
description: Scaffold gem release prep (version bump, CHANGELOG stamp, lockfile, tests, dummy-app smoke)
argument-hint: [patch|minor|major|X.Y.Z]
allowed-tools: Bash(git status:*), Bash(git fetch:*), Bash(git log:*), Bash(git diff:*), Bash(git tag:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git checkout:*), Bash(git switch:*), Bash(git restore:*), Bash(gh pr view:*), Bash(gh pr create:*), Bash(bundle install:*), Bash(bundle exec:*), Bash(grep:*), Bash(rg:*), Bash(ls:*), Bash(date:*), Read, Edit, Write, Glob, Grep
---

Prepare a gem release for the current repo. Bump kind: **$ARGUMENTS** (empty = infer from commits since last tag).

This skill does the **boring prep** — version bump, CHANGELOG stamp, lockfile refresh, tests, dummy-app smoke test. It **never** pushes, tags, or publishes. Shared-state actions stay with the user.

## Stop and ask before proceeding past any ⛔ checkpoint below.

## 1. Parse the bump kind

- `$ARGUMENTS` empty → infer (see step 3)
- `patch` / `minor` / `major` → bump that segment of current `lib/a11y/lint/version.rb`
- `X.Y.Z` (matches `^\d+\.\d+\.\d+$`) → use literally
- Anything else → bail and ask

## 2. Preflight ⛔

Run these checks. **Bail loudly on any failure** — do not "fix" the state silently.

- `git rev-parse --abbrev-ref HEAD` → must be `main`
- `git status --porcelain` → must be empty (clean tree)
- `git fetch origin main` then compare `git rev-list --count HEAD..origin/main` → must be `0` (not behind)
- Read `lib/a11y/lint/version.rb`, parse `VERSION`, and confirm it matches:
  - The `a11y-lint (X.Y.Z)` line in `Gemfile.lock` (under `PATH` → `specs:`)
  - The latest tag from `git tag --sort=-v:refname | head -1` (stripped of leading `v`)
- All three must agree. If they don't, surface the mismatch and stop — it usually means a prior release was half-finished.

## 3. Infer the bump (only if `$ARGUMENTS` empty)

- Latest tag: `git tag --sort=-v:refname | head -1`
- Commits since: `git log <latest_tag>..HEAD --pretty=format:'%h %s%n%b%n---'`
- Heuristic, in order:
  - Any commit subject or body containing `Breaking` (case-sensitive) → **major**
  - Else any subject starting with `Add ` or `Change ` → **minor**
  - Else (typically all `Fix `) → **patch**
- Show the inferred bump, the next version it implies, and the commits it was based on. ⛔ **Confirm with the user before proceeding.**

## 4. CHANGELOG sanity check ⛔

- Read `CHANGELOG.md`'s `[Unreleased]` block (everything between `## [Unreleased]` and the next `## [`).
- List the commits from step 3 (or `git log <latest_tag>..HEAD --oneline` if step 3 was skipped).
- For each commit, try to match it against an Unreleased entry:
  - First, look for the commit's PR number (e.g. `(#88)` in the subject) anywhere in the Unreleased block.
  - If no PR number match, fall back to keyword overlap (rule class names, helper names) — this is approximate; surface uncertainty rather than guess.
- Print a coverage table: each commit → matched / unmatched / likely-chore-or-refactor.
- ⛔ Ask the user to confirm coverage. Don't proceed if any user-visible commit looks unmatched.

## 5. Apply the bump

Compute target `X.Y.Z` (from `$ARGUMENTS` or step 3). Then:

1. **Edit `lib/a11y/lint/version.rb`** — replace the `VERSION = "..."` literal.
2. **Edit `CHANGELOG.md`** — insert a new heading **directly below** `## [Unreleased]`, with a blank line on each side, leaving the Unreleased block empty:
   ```
   ## [Unreleased]

   ## [X.Y.Z] - YYYY-MM-DD

   ### Fixed
   ... (existing entries shift down under the new heading) ...
   ```
   Use today's date in absolute `YYYY-MM-DD` form (`date +%Y-%m-%d`). The previous Unreleased entries are now attributed to this release; the new Unreleased block is empty.
3. `bundle install` — refreshes `Gemfile.lock`'s `a11y-lint (X.Y.Z)` line. Should be a tiny diff. If `bundle install` touches anything else, surface it and ⛔ ask before continuing.

## 6. Run the suite ⛔

- `bundle exec rake` — tests + RuboCop. Bail on any failure; do not press on with a red suite.

## 7. Dummy-app smoke test ⛔

- `bundle exec a11y-lint test/fixtures/dummy_app` — must run end-to-end without crashing.
- Capture the offense count from the output.
- For comparison, fetch the previous release's count by temporarily reverting just the fixtures:
  ```
  git checkout <latest_tag> -- test/fixtures/dummy_app
  bundle exec a11y-lint test/fixtures/dummy_app  # capture count
  git checkout HEAD -- test/fixtures/dummy_app   # restore current fixtures
  ```
  This compares "current linter on previous fixtures" vs "current linter on current fixtures" — a regression in linter behavior on stable fixtures will jump out.
- Report the delta (`prev → current`). ⛔ If the count moved unexpectedly, surface it and ask before continuing.

## 8. Show the diff ⛔

- `git diff --stat` — should touch only `lib/a11y/lint/version.rb`, `CHANGELOG.md`, `Gemfile.lock`. Anything else is a red flag.
- `git diff` — the full release diff for the user to eyeball.
- ⛔ Wait for user sign-off on the diff before the handoff step.

## 9. Handoff ⛔ (shared-state — never run unprompted)

Offer three options. **Do not pick one for the user.** ⛔ Wait for an explicit choice.

- **A. PR branch:**
  ```
  git checkout -b release-X.Y.Z
  git add CHANGELOG.md Gemfile.lock lib/a11y/lint/version.rb
  git commit -m "Release X.Y.Z"
  git push -u origin release-X.Y.Z
  gh pr create --title "Release X.Y.Z" --body "..."
  ```
- **B. Commit on main:**
  ```
  git add CHANGELOG.md Gemfile.lock lib/a11y/lint/version.rb
  git commit -m "Release X.Y.Z"
  ```
  (User pushes manually.)
- **C. Stop here** — user wants to take it from the working tree.

**Mention but never run** these — they publish to RubyGems / push tags and are irreversible:
- `bundle exec rake release` (builds, tags, pushes to RubyGems in one step)
- `gem push pkg/a11y-lint-X.Y.Z.gem`
- `git tag vX.Y.Z && git push origin vX.Y.Z`

## Out of scope

- Auto-generating CHANGELOG entries from commits — entries are hand-written during each PR with care; generated bullets would be worse than what's already there.
- Auto-push, auto-tag, auto-publish.
- Cleverness about SemVer beyond the inferred-bump suggestion — the user can always override by passing `X.Y.Z` explicitly.

## Style notes

- Be concrete. Show numbers (commit count, offense count, file count) — they're cheap and they catch mistakes.
- One ⛔ checkpoint per phase. Don't batch confirmations.
- When in doubt about whether a commit needs a CHANGELOG entry, **ask the user**. Don't decide unilaterally.
