# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
