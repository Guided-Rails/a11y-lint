---
description: Scaffold gem release prep — preflight, bump, smoke, then push a release branch and open a PR
argument-hint: [patch|minor|major|X.Y.Z]
allowed-tools: Bash(git status:*), Bash(git fetch:*), Bash(git log:*), Bash(git diff:*), Bash(git tag:*), Bash(git rev-parse:*), Bash(git rev-list:*), Bash(git branch:*), Bash(git checkout:*), Bash(git switch:*), Bash(git restore:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(bundle install:*), Bash(bundle exec:*), Bash(grep:*), Bash(rg:*), Bash(ls:*), Bash(date:*), Read, Edit, Write, Glob, Grep
---

Prepare a gem release. Bump kind: **$ARGUMENTS** (empty = infer from commits since last tag).

End state: a `release-X.Y.Z` branch pushed to origin with an open PR titled `Release X.Y.Z` and body `🎉`. The PR diff is the review surface — the CHANGELOG is the release notes.

The user runs the irreversible steps after the PR merges. **Never** run `bundle exec rake release`, `gem push pkg/a11y-lint-X.Y.Z.gem`, or `git tag vX.Y.Z && git push origin vX.Y.Z`.

## Preflight

Bail loudly on any failure — don't try to fix state silently.

- On `main`, working tree clean, not behind `origin/main` (`git fetch origin main` then `git rev-list --count HEAD..origin/main` → `0`).
- `lib/a11y/lint/version.rb` `VERSION`, `Gemfile.lock`'s `a11y-lint (X.Y.Z)` line under `PATH → specs:`, and the latest `git tag --sort=-v:refname | head -1` (stripped of leading `v`) all agree. A mismatch usually means a prior release was half-finished — surface it and stop.

## Bump

If `$ARGUMENTS` is empty, infer from `git log <latest_tag>..HEAD`:

- Any commit subject containing `Breaking`, or starting with `Add ` or `Change ` → **minor**
- Otherwise → **patch**

This gem is pre-1.0; breaking changes still bump the minor (no major path). Print the inferred bump and the resulting `X.Y.Z`, then proceed without confirming.

If `$ARGUMENTS` is `patch`/`minor`/`major`, bump that segment. If it's `X.Y.Z`, use literally. Anything else → bail.

## Apply

1. Edit `lib/a11y/lint/version.rb` — replace the `VERSION = "..."` literal.
2. Edit `CHANGELOG.md` — insert `## [X.Y.Z] - YYYY-MM-DD` (today, absolute via `date +%Y-%m-%d`) directly below `## [Unreleased]` with blank lines around it. The Unreleased entries shift down to attribute the new release; the new Unreleased block stays empty.
3. `bundle install` — should change only `Gemfile.lock`'s `a11y-lint (X.Y.Z)` line. Surface anything else.

## Verify

- `bundle exec rake` — tests + RuboCop. Bail on red.
- `bundle exec a11y-lint test/fixtures/dummy_app` — capture offense count. Then run the same command against the prior release's fixtures with the *current* linter to isolate any linter regression on stable input:
  ```
  git checkout <latest_tag> -- test/fixtures/dummy_app
  bundle exec a11y-lint test/fixtures/dummy_app
  git checkout HEAD -- test/fixtures/dummy_app
  ```
  Report `prev → current`. A non-trivial change is a linter regression — surface it.

## Shape check

`git diff --stat` should touch only `lib/a11y/lint/version.rb`, `CHANGELOG.md`, `Gemfile.lock`. Anything else is a red flag — stop and ask before pushing.

## Branch + PR

```
git checkout -b release-X.Y.Z
git add lib/a11y/lint/version.rb CHANGELOG.md Gemfile.lock
git commit -m "Release X.Y.Z"
git push -u origin release-X.Y.Z
gh pr create --title "Release X.Y.Z" --body "🎉"
```

Print the PR URL.
