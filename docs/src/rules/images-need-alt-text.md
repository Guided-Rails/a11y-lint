---
layout: page
title: Images need alt text
permalink: /rules/images-need-alt-text/
wcag: "1.1.1 Non-text Content (Level A)"
---

## Why it matters

Screen readers can't see images. When an `<img>` has no `alt` attribute, assistive tech has nothing meaningful to announce. It either falls back to reading the filename ("logo dot png") or skips the image silently. Either way, a screen reader user loses information that sighted users get for free.

These rules cover the [WCAG 2.2 Success Criterion 1.1.1 Non-text Content (Level A)](https://www.w3.org/TR/WCAG22/#non-text-content).

## Choosing alt text

a11y-lint enforces that an `alt` is *present*. It can't judge what's *in* it, and the content is where most teams get alt text wrong.

### Decorative vs. informative

Would a sighted user lose information if the image were removed? If yes, the image is informative; write a short, specific `alt` describing what it conveys. If no, it's decorative; use `alt=""`.

An empty `alt` is **not** a missing `alt`. It explicitly tells assistive tech to skip the image, which is what you want for decoration. a11y-lint treats `alt=""` and `alt: ""` as valid.

### Functional images (image as link or button)

When an image is the entire content of a link or button, describe the **destination or action**, not the picture. An image-only link to the home page is `alt="GuidedRails home"`, not `alt="GuidedRails logo"`:

```erb
<%%= link_to image_tag("logo.svg", alt: "GuidedRails home"), root_path %>
```

The image's alt becomes the link's accessible name. This is the W3C's primary technique for functional images. See the [WAI Functional Images tutorial](https://www.w3.org/WAI/tutorials/images/functional/) for more.

### Image inside a link with visible text

The visible text is already the link's accessible name. Mark the image as decorative so screen readers don't announce it twice:

```erb
<%%= link_to root_path do %>
  <%%= image_tag "home-icon.svg", alt: "" %> Home
<%% end %>
```

`aria-label` on the link with `alt=""` on the image is also valid, but the alt-on-image approach is preferred where it works: `alt` survives browser translation, shows up in more tools, and doesn't depend on ARIA support.

### Image with an adjacent caption

If surrounding visible text already describes the image, use `alt=""`. Don't repeat in `alt` what the caption already says. That doubles the announcement for screen reader users.

### Charts, diagrams, complex images

Pair a short alt (the headline takeaway) with a longer description nearby. Use a `<figcaption>`, prose on the page, or a hidden description referenced by `aria-describedby`. Alt text alone is the wrong tool for explaining a chart.

### Anti-patterns

These all pass the linter and all fail real users:

- `alt="image"`, `alt="photo"`, `alt="picture of…"`
- Alt text that's just the filename: `alt="hero.jpg"`
- Alt text that duplicates adjacent visible text
- Describing the image when you should be describing the link's destination

## ImgMissingAlt
{:#img-missing-alt}

Applies to: HTML `<img>` elements.

### Bad

```erb
<img src="hero.jpg">
```

### Good

```erb
<img src="hero.jpg" alt="Team celebrating after a product launch">
```

For a decorative image, use an empty `alt` so assistive tech skips it:

```erb
<img src="divider.svg" alt="">
```

### Slim and Phlex equivalents

Slim:

```slim
img src="hero.jpg" alt="Team celebrating after a product launch"
```

Phlex:

```ruby
img(src: "hero.jpg", alt: "Team celebrating after a product launch")
```

## ImageTagMissingAlt
{:#image-tag-missing-alt}

Applies to: Rails `image_tag` helper.

### Bad

```erb
<%%= image_tag("hero.jpg") %>
```

### Good

```erb
<%%= image_tag("hero.jpg", alt: "Team celebrating after a product launch") %>
```

For a decorative image:

```erb
<%%= image_tag("divider.svg", alt: "") %>
```

### Slim and Phlex equivalents

Slim:

```slim
= image_tag("hero.jpg", alt: "Team celebrating after a product launch")
```

Phlex:

```ruby
image_tag("hero.jpg", alt: "Team celebrating after a product launch")
```

## InputImageMissingAlt
{:#input-image-missing-alt}

Applies to: HTML `<input type="image">` elements.

`<input type="image">` is a submit button rendered as an image. It's a button first, an image second. The `alt` should describe the **action the button performs**, not what the image looks like. The linter accepts `alt=""` here, but you shouldn't use it — a submit button with no accessible name leaves users unable to know what they're activating.

### Bad

```erb
<input type="image" src="search.svg">
```

### Good

```erb
<input type="image" src="search.svg" alt="Search">
```

### Slim and Phlex equivalents

Slim:

```slim
input type="image" src="search.svg" alt="Search"
```

Phlex:

```ruby
input(type: "image", src: "search.svg", alt: "Search")
```

## ImageSubmitTagMissingAlt
{:#image-submit-tag-missing-alt}

Applies to: Rails `image_submit_tag` helper (renders `<input type="image">`).

`image_submit_tag` is a submit button rendered as an image. It's a button first, an image second. The `alt` should describe the **action the button performs**, not what the image looks like. The linter accepts `alt: ""` here, but you shouldn't use it — a submit button with no accessible name leaves users unable to know what they're activating.

### Bad

```erb
<%%= image_submit_tag("search.svg") %>
```

### Good

```erb
<%%= image_submit_tag("search.svg", alt: "Search") %>
```

### Slim and Phlex equivalents

Slim:

```slim
= image_submit_tag("search.svg", alt: "Search")
```

Phlex:

```ruby
image_submit_tag("search.svg", alt: "Search")
```

WCAG reference: technique [H36](https://www.w3.org/WAI/WCAG22/Techniques/html/H36) (applies to both `InputImageMissingAlt` and `ImageSubmitTagMissingAlt`).

## AreaMissingAlt
{:#area-missing-alt}

Applies to: HTML `<area>` elements inside an image map (`<map>`).

Each `<area>` is a clickable hotspot in an image map — effectively a link. Its `alt` becomes the link's accessible name, so describe the **destination**, not the slice of the image. An empty `alt` is not appropriate; a hotspot with no accessible name is an unlabeled link.

### Bad

```erb
<img src="team-photo.jpg" alt="Our team" usemap="#team">
<map name="team">
  <area shape="rect" coords="0,0,100,100" href="/team/alex">
</map>
```

### Good

```erb
<img src="team-photo.jpg" alt="Our team" usemap="#team">
<map name="team">
  <area shape="rect" coords="0,0,100,100" href="/team/alex" alt="Alex's profile">
</map>
```

### Slim and Phlex equivalents

Slim:

```slim
img src="team-photo.jpg" alt="Our team" usemap="#team"
map name="team"
  area shape="rect" coords="0,0,100,100" href="/team/alex" alt="Alex's profile"
```

Phlex:

```ruby
img(src: "team-photo.jpg", alt: "Our team", usemap: "#team")
map(name: "team") do
  area(shape: "rect", coords: "0,0,100,100", href: "/team/alex", alt: "Alex's profile")
end
```

WCAG reference: technique [H24](https://www.w3.org/WAI/WCAG22/Techniques/html/H24).

## What these rules don't catch

These rules check that `alt` is **present**. They don't judge content, runtime values, or alternative accessibility mechanisms. Things you still need to verify yourself:

- **Bad alt content.** `alt="image"`, `alt="hero.jpg"`, alt that duplicates adjacent visible text. All of these pass the linter.
- **Dynamic alt values.** `alt: image.caption` satisfies the rule even if `caption` returns `nil` or an empty string for a non-decorative image. The linter sees the keyword, not the value.
- **Inline `<svg>` elements.** These rules target `<img>` and the Rails helpers only. Inline SVGs that convey information need their own accessible name (`<title>`, `aria-label`, or `aria-labelledby`), which is outside the scope of this rule.
- **CSS `background-image`.** Background images are invisible to screen readers. Don't use them for informative content; the linter can't help either way.
- **`aria-label` / `aria-labelledby` as alt substitutes.** ARIA can technically provide an accessible name for an image, but a11y-lint is opinionated. In Rails templates, it expects `alt`. An `<img>` with `aria-label` and no `alt` is still flagged.
- **Functional-image judgement.** A valid alt that describes the picture when it should describe the link's destination still passes. See [Choosing alt text](#choosing-alt-text).
