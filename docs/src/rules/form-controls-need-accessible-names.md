---
layout: page
title: Form controls need accessible names
permalink: /rules/form-controls-need-accessible-names/
wcag: "4.1.2 Name, Role, Value (Level A)"
---

## Why it matters

A form control with no accessible name leaves screen reader users guessing at its purpose. They hear "combo box" or "edit" with nothing to anchor it to — no field name, no instruction. The only way to recover is to read surrounding context, open the control and inspect its options, or give up. Sighted users get the label for free; screen reader users shouldn't have to work harder for the same information.

This rule covers the [WCAG 2.2 Success Criterion 4.1.2 Name, Role, Value (Level A)](https://www.w3.org/TR/WCAG22/#name-role-value).

## How form controls get an accessible name

Prefer a visible `<label>`. In Simple Form, that means letting the helper render its default label or passing an explicit string: `label: "Sort by"`. Visible labels help everyone — sighted users, screen reader users, voice control users speaking the field name — and they survive translation and browser autofill.

If the design genuinely calls for a control with no visible label — typically a control whose purpose is obvious from its surroundings, like a "Sort by" select on a search results page — the control still needs an accessible name. Provide it explicitly with one of:

- `aria-label` on the control: a short string read by assistive tech.
- `aria-labelledby` pointing to the id of visible text elsewhere on the page.

In Simple Form, both go inside `input_html`:

```erb
<%%= form.input :sort_by, collection: opts, label: false,
      input_html: { aria: { label: "Sort by" } } %>
```

A placeholder is **not** a label. It disappears as soon as the user types, browsers don't reliably expose it as the accessible name, and it fails users who rely on the prompt staying visible while they fill the field.

## SimpleFormInputMissingAccessibleName
{:#simple-form-input-missing-accessible-name}

Applies to: Simple Form `form.input` calls with `label: false` or `label: ""` — regardless of input type. `as: :hidden` is skipped, since hidden inputs don't render a visible control.

The rule passes when `input_html` provides `aria-label` or `aria-labelledby`. Both hash and string keys are accepted (`aria: { label: "..." }` and `"aria-label" => "..."`).

### Bad

```erb
<%%= form.input :name, label: false %>
```

```erb
<%%= form.input :sort_by, collection: opts, label: false %>
```

```erb
<%%= form.input :sort_by, as: :select, label: false %>
```

### Good

Render a visible label by removing `label: false` and letting Simple Form generate one from the attribute name, or by passing an explicit string:

```erb
<%%= form.input :name %>
<%%= form.input :sort_by, collection: opts, label: "Sort by" %>
```

Or, when there's no visible label, supply `aria-label`:

```erb
<%%= form.input :name, label: false,
      input_html: { aria: { label: "Name" } } %>
```

Or `aria-labelledby` pointing to existing visible text:

```erb
<h2 id="sort-label">Sort by</h2>
<%%= form.input :sort_by, collection: opts, label: false,
      input_html: { aria: { labelledby: "sort-label" } } %>
```

`as: :hidden` doesn't render a visible control, so it's exempt:

```erb
<%%= form.input :secret, as: :hidden, label: false %>
```

### Slim equivalent

```slim
= form.input :name, label: false, input_html: { aria: { label: "Name" } }
```

## What this rule doesn't catch

This rule has a deliberately narrow scope. Things it doesn't flag:

- **Plain HTML form controls.** The rule targets Simple Form's `form.input` helper. A bare `<input>`, `<select>`, or `<textarea>` with no associated `<label>` is not reported.
- **Other Simple Form helpers.** `form.select`, `form.association`, and similar helpers aren't checked — only `form.input`.
- **Inputs without `label: false`.** Simple Form auto-generates a label from the attribute name, so `form.input :name` is treated as having a visible label. The rule only kicks in once the label is explicitly suppressed.
- **Phlex views.** The rule is a no-op in Phlex by design. The Phlex pipeline only walks receiverless calls, so `form.input(...)` isn't surfaced as a candidate node. Simple Form code embedded inside a Phlex component won't be checked.
- **Bad accessible name content.** `aria: { label: "" }` will pass the rule check above (an empty aria-label is its own problem, but not this rule's). `aria: { label: "select" }` will pass. The linter checks that an aria attribute is present, not that the value is useful.
- **Dynamic accessible names.** `aria: { label: variable }` satisfies the rule even if `variable` is `nil` at runtime.
- **`aria-labelledby` pointing nowhere.** The rule doesn't verify that the referenced id exists in the rendered HTML.
