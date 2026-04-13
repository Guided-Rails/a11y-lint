# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
