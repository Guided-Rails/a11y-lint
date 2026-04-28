---
description: Capture a free-form idea as a GitHub issue in the current repo
argument-hint: <idea>
allowed-tools: Bash(gh issue create:*), Bash(gh repo view:*), Bash(grep:*), Bash(rg:*), Bash(ls:*), Bash(find:*), Read, Glob, Grep
---

Take the free-form idea below and turn it into a well-formed GitHub issue in the current repo.

Idea: $ARGUMENTS

## What to do

1. **Refine** the idea into:
   - A clear **title** (≤ ~70 chars, sentence case, no trailing period)
   - A **body** with these sections (omit any that don't apply):
     - **Problem / idea** — restate the idea clearly in 1–3 sentences
     - **Proposed approach** — only include if the approach is obvious from the idea
     - **Files likely involved** — only include if you can quickly identify them from the repo (e.g. a new rule idea should point at the right WCAG principle directory under `lib/a11y/lint/rules/`)

2. **Clarify only if necessary** — one round, max. Voice input drops context, but too many questions defeat frictionless capture. Skip clarification when the idea is unambiguous. Typical clarifications: bug vs. feature, which rule/file, which template pipeline (Slim/ERB/Phlex).

3. **Create the issue** with `gh issue create --title "..." --body "$(cat <<'EOF' ... EOF)"` against the current repo. Do **not** pass `--repo`. Do **not** add labels.

4. **Return the issue URL** that `gh issue create` prints. Keep your final reply to one line — just the URL (and a one-line summary if helpful).

## Out of scope

- Auto-suggesting labels
- Cross-repo support
- Duplicate detection / linking related issues
- Editing or closing existing issues

## Style notes

- Bias toward **fast capture** over thoroughness — the issue can always be edited on GitHub.
- Don't pad the body with boilerplate. If "Proposed approach" or "Files likely involved" isn't obvious, leave it out.
- Match the tone of recent issues in this repo if you can quickly check one.
