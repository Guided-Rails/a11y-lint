# Contributing to the a11y-lint docs site

## Authoring rule reference pages

Rule pages live in `src/rules/`, one Markdown file per WCAG concept. Each rule class is an anchor section within that page.

### Showing example code in multiple template languages

a11y-lint supports ERB, Slim, and Phlex. When a rule page shows example code, render it through the `Shared::CodeTabs` component so all three pipelines collapse into one tabbed block instead of three stacked code blocks.

ERB is required and is the default tab. Slim and Phlex are optional — omit either kwarg and the tab won't render.

```erb
<%= render Shared::CodeTabs.new(
  erb: <<~ERB,
    <img src="hero.jpg" alt="Team celebrating after a product launch">
  ERB
  slim: <<~SLIM,
    img src="hero.jpg" alt="Team celebrating after a product launch"
  SLIM
  phlex: <<~PHLEX,
    img(src: "hero.jpg", alt: "Team celebrating after a product launch")
  PHLEX
) %>
```

The component takes care of:

- Rouge syntax highlighting per tab (using the `erb`, `slim`, and `ruby` lexers).
- WAI-ARIA tab pattern: `role="tablist"` / `role="tab"` / `role="tabpanel"` with full `aria-*` wiring.
- Keyboard navigation: Left/Right arrows move between tabs, Home/End jump to the first/last tab, Enter/Space activate, Tab moves into the panel.
- A no-JavaScript fallback that shows the ERB panel only.
- `prefers-reduced-motion`.

Multiple instances on the same page get unique IDs automatically.
