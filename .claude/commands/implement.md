---
description: Plan and implement a GitHub issue end-to-end on a new branch
argument-hint: <issue-number>
allowed-tools: Bash(gh issue view:*), Bash(gh repo view:*), Bash(git checkout:*), Bash(git switch:*), Bash(git branch:*), Bash(git status:*), Bash(git diff:*), Bash(bundle exec:*), Bash(bin/setup:*), Bash(bin/console:*), Bash(grep:*), Bash(rg:*), Bash(ls:*), Bash(find:*), Read, Edit, Write, Glob, Grep
---

Plan and implement GitHub issue **#$ARGUMENTS** in this repo, end-to-end, on a fresh branch. Do **not** commit or push — leave the working tree dirty for the user to review.

## What to do

1. **Fetch the issue.** Run `gh issue view $ARGUMENTS` (and `gh issue view $ARGUMENTS --comments` if there are comments) to read the title, body, and any discussion. Do **not** pass `--repo`.

2. **Create a branch.** From the current branch, run `git checkout -b <slug>` where `<slug>` is `issue-$ARGUMENTS-<short-kebab-summary>` (e.g. `issue-87-anchor-button-phlex-helpers`). Keep it under ~50 chars. If the branch already exists, switch to it instead.

3. **Plan before coding.** Produce a short plan covering:
   - Which files you'll touch or create
   - For new rules: the WCAG principle directory under `lib/a11y/lint/rules/`, the rule class name (see CLAUDE.md "Rule Scoping Convention"), and whether it has an HTML/helper pair
   - Tests to add (Slim + ERB + Phlex parity per `.claude/rules/testing.md`)
   - Dummy app fixtures to add in `test/fixtures/dummy_app/app/views/home/home.html.{slim,erb}` and any Phlex view
   - Open questions, if any — ask once, then proceed

4. **Implement the plan.**
   - Follow `CLAUDE.md` (rule scoping, node interface, configuration loading) and `.claude/rules/testing.md` (no `setup`, all three calling styles for `ruby_code` rules, Slim/ERB/Phlex parity, inline HEREDOC fixtures).
   - For new rules: register the rule, add good/bad examples to dummy app fixtures, and add a docs page under `docs/src/rules/` if the issue is adding a user-visible rule.
   - Add an entry under `[Unreleased]` in `CHANGELOG.md` for any user-visible change (bug fixes, new rules, behavior changes). Skip for internal refactors and test-only changes.

5. **Run the suite until green.** `bundle exec rake` runs tests + RuboCop. Iterate on failures. If a fix is non-obvious, surface it before grinding.

6. **Stop without committing.** Leave changes staged-or-unstaged in the working tree. In your final reply:
   - List the branch name
   - Summarize what changed (files added/modified, tests added)
   - Confirm `bundle exec rake` is green (or call out what's still failing and why)
   - Suggest the next command (`git add -A && git commit -m "..."` or a `gh pr create` once the user is ready) — but do **not** run it

## Out of scope

- Committing, pushing, or opening a PR
- Cross-repo support
- Auto-closing the issue
- Picking the issue automatically (always passed explicitly)

## Style notes

- Plan first, code second. A 5-line plan beats a 50-line one.
- Match the conventions of recent rules and recent commits — skim `git log --oneline -20` and a nearby rule file before inventing a new pattern.
- If the issue is ambiguous, ask **one** round of clarifying questions before implementing — voice input drops context, but too many questions defeat the point.
