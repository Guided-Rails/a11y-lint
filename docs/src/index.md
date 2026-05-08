---
layout: default
---

# README

Catch accessibility bugs in your Rails templates before they ship.

a11y-lint is a Ruby gem that lints Rails view code — Slim, ERB, and Phlex — for accessibility mistakes that browser-based checkers can only see *after* a page has rendered. It runs against your template source, in CI, on every PR, before any HTML reaches a user.

## What it catches

a11y-lint focuses on issues that are unambiguously wrong in source code — the kind of mistakes a static check should catch so that human review can spend its attention on judgement calls. Two rule sets ship today:

- [Images need alt text](/rules/images-need-alt-text/) — `<img>`, `<area>`, `<input type="image">`, and the matching Rails helpers (`image_tag`, `image_submit_tag`) with no `alt` attribute. Covers WCAG 1.1.1.
- [Form controls need accessible names](/rules/form-controls-need-accessible-names/) — Simple Form `form.input` calls that suppress the visible label without providing an `aria-label` or `aria-labelledby`. Covers WCAG 4.1.2.

More are on the way. See the [rule reference](/rules/images-need-alt-text/) for the full set, including what each rule does and doesn't catch.

## Who it's for

Rails apps that render views with **Slim**, **ERB**, or **Phlex**. The same rules run across all three pipelines, so a mixed codebase is a first-class case rather than an afterthought.

It's most useful on teams that:

- Want accessibility caught at PR time, not in a manual audit weeks later.
- Already run RuboCop in CI and want to add a11y checks to the same step.
- Have a long-lived codebase where templates have drifted across formats.

## Install

Add the gem to your `Gemfile`:

```ruby
gem "a11y-lint"
```

Then run it against your views:

```bash
bundle exec a11y-lint app/views
```

With no arguments it scans the current directory recursively for `.slim`, `.erb`, and `.rb` (Phlex) files.

To enable or disable specific rules, drop a `.a11y-lint.yml` at your project root:

```yaml
ImgMissingAlt:
  Enabled: false
```

Rules not listed are enabled by default. The full configuration format is on the [GitHub README](https://github.com/Guided-Rails/a11y-lint#configuration).

## What's next

- Read the [rule reference](/rules/images-need-alt-text/) to see what each rule catches and where it stops.
- Source and issue tracker: [github.com/Guided-Rails/a11y-lint](https://github.com/Guided-Rails/a11y-lint).
