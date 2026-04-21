# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.11.0] - 2026-04-21

### Added

- `AreaMissingAlt` rule: detects `<area>` tags without `alt` attributes (WCAG 1.1.1)
- `InputImageMissingAlt` rule: detects `<input type="image">` tags without `alt` attributes (WCAG 1.1.1)
- `ImageSubmitTagMissingAlt` rule: detects `image_submit_tag` calls without an `alt` option (WCAG 1.1.1)
- `InputMissingAutocomplete` rule: detects `<input>` elements without an `autocomplete` attribute (WCAG 1.3.5)
- `AnchorMissingAccessibleName` rule: detects `<a>` elements without text content, `aria-label`, or a child image with `alt` (WCAG 4.1.2)
- `ButtonMissingAccessibleName` rule: detects `<button>` elements without text content, `aria-label`, or a child image with `alt` (WCAG 4.1.2)

### Changed

- **Breaking:** Split `MissingAccessibleName` into `LinkToMissingAccessibleName` (for `link_to`/`external_link_to`) and `ButtonTagMissingAccessibleName` (for `button_tag`) to follow one-rule-per-helper convention
- **Breaking:** Rename `A11y::Lint::Rule` to `A11y::Lint::NodeRule`. Custom rules that subclass the base class must update the parent class name
- Auto-require all rule files instead of listing them individually
- Node attribute storage now preserves string values, enabling rules to check attribute values (not just existence)
- `.a11y-lint.yml` now supports a top-level `hidden_wrapper_classes` list; content inside elements whose class matches is treated as hidden from assistive technology when the four accessible-name rules (`AnchorMissingAccessibleName`, `ButtonMissingAccessibleName`, `LinkToMissingAccessibleName`, `ButtonTagMissingAccessibleName`) determine whether a button/link has an accessible name. Opt-in; default is no filtering

### Fixed

- `LinkToMissingAccessibleName` / `ButtonTagMissingAccessibleName`: no longer flag `link_to`/`button_tag` blocks containing an `image_tag` with a non-empty `alt` option

## [0.10.0] - 2026-04-15

### Changed

- Introduce `A11y::Lint::CallNode` wrapper so rules express accessibility logic, not AST traversal
- Expose Prism `CallNode` from `SlimNode` and `ErbNode` via the new `RubyCode` parser
- Expose Prism `CallNode` from `PhlexNode` instead of converting to string
- Extract Phlex HTML tag constants into `PhlexTags` module

## [0.9.0] - 2026-04-15

### Changed

- **Breaking:** Require Ruby >= 3.3.0 (was 3.1.0). Prism ships with Ruby 3.3+ as a bundled gem
- **Breaking:** `slim` is now an optional dependency. Add `gem "slim"` to your Gemfile if you lint `.slim` files. A `SlimLoadError` is raised with a helpful message if the gem is missing
- `prism` is no longer a declared dependency (bundled with Ruby 3.3+)
- Replace Ripper with Prism for Ruby code parsing in `ImageTagMissingAlt` and `MissingAccessibleName` rules
- Custom error classes are now defined in `lib/a11y/lint/errors.rb`

### Fixed

- `MissingAccessibleName`: fix false positive when block contains visible text or HTML tags (e.g. `link_to do` with a `span` or plain text inside)
- Add `block_body_codes` and `block_has_text_children?` to all three node types (Slim, ERB, Phlex) so block content inspection works across all pipelines

## [0.8.0] - 2026-04-14

### Added

- Phlex view support: scans `.rb` files containing Phlex components
  - Detects Phlex files by the presence of a `def view_template` method
  - All existing rules (`ImgMissingAlt`, `ImageTagMissingAlt`, `ListInvalidChildren`, `MissingAccessibleName`) work with Phlex views
  - CLI automatically discovers `.rb` files when scanning directories

### Changed

- **Breaking:** `Node` has been renamed to `SlimNode` for consistency with `ErbNode` and `PhlexNode`

### Dependencies

- Added `prism` gem for Ruby AST parsing

## [0.7.2] - 2026-04-13

### Fixed

- ERB runner: skip phantom elements created when Nokogiri interprets text-mentioned HTML tags as real elements

## [0.7.1] - 2026-04-13

### Fixed

- Slim runner: correct line numbers in templates with multiline backslash continuations

## [0.7.0] - 2026-04-13

### Added

- `ListInvalidChildren` rule: detects invalid direct children of `<ul>` and `<ol>` elements (WCAG 1.3.1)
- `MissingAccessibleName` rule: consolidates `LinkMissingAccessibleName` into a single rule covering `link_to`, `external_link_to`, and `button_tag`
- Per-rule configuration via `.a11y-lint.yml` file: enable or disable individual rules
  - Place `.a11y-lint.yml` in the project root for automatic detection
  - Use `--config PATH` to specify a custom configuration file path

### Removed

- `LinkMissingAccessibleName` rule: replaced by `MissingAccessibleName`

## [0.6.0] - 2026-03-31

### Added

- `LinkMissingAccessibleName` rule: detect block-style `link_to` calls missing an `aria-label`

## [0.5.1] - 2026-03-31

### Fixed

- `LinkMissingAccessibleName` rule: detect multiline method calls with trailing commas

## [0.5.0] - 2026-03-31

### Added

- `LinkMissingAccessibleName` rule: detects `<a>` tags without accessible text content

## [0.4.0] - 2026-03-27

### Added

- ERB template support: scans `.erb` files using Nokogiri for HTML parsing
  - Both `ImgMissingAlt` and `ImageTagMissingAlt` rules now work on ERB templates
  - CLI automatically detects and routes `.slim` and `.erb` files to the appropriate runner

### Changed

- **Breaking:** `Runner` has been renamed to `SlimRunner`

## [0.3.1] - 2026-03-27

### Fixed

- `ImageTagMissingAlt` rule: detect `image_tag` nested inside `link_to` and other helper calls

## [0.3.0] - 2026-03-27

### Added

- `ImageTagMissingAlt` rule: detects `image_tag` calls without an `alt` option

## [0.2.0] - 2026-03-27

### Added

- Command-line interface (`exe/a11y-lint`) for running the linter from the terminal
  - Accepts file paths and directories as arguments
  - Recursively scans for `.slim` files when given a directory (defaults to current directory)
  - Supports `--version` and `--help` flags

## [0.1.0] - 2026-03-27

### Added

- AST-based Slim template linter
- `ImgMissingAlt` rule: detects `img` tags without `alt` attributes
