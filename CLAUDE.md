# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

a11y-lint is a Ruby gem (v0.1.0) for accessibility linting. It uses the `A11y::Lint` module namespace. Requires Ruby >= 3.1.0.

## Commands

- **Install dependencies:** `bin/setup` or `bundle install`
- **Run all checks (tests + linting):** `bundle exec rake`
- **Run tests only:** `bundle exec rake test`
- **Run a single test file:** `bundle exec ruby -Ilib:test test/a11y/test_lint.rb`
- **Run a single test by name:** `bundle exec ruby -Ilib:test test/a11y/test_lint.rb -n test_name`
- **Run linter:** `bundle exec rake rubocop`
- **Run a11y-lint on files:** `bundle exec a11y-lint [file_or_directory ...]`
- **Interactive console with gem loaded:** `bin/console`

## Architecture

- **CLI:** `lib/a11y/lint/cli.rb` — command-line interface; executable at `exe/a11y-lint`; routes `.slim` files to `SlimRunner` and `.erb` files to `ErbRunner`
- **Entry point:** `lib/a11y/lint.rb` — defines the `A11y::Lint` module and `A11y::Lint::Error` exception
- **Slim pipeline:** `SlimRunner` parses Slim templates via `Slim::Parser`; `Node` wraps Slim S-expressions
- **ERB pipeline:** `ErbRunner` parses ERB templates via Nokogiri; `ErbNode` wraps Nokogiri nodes and extracted `<%= %>` Ruby code
- **Configuration:** `lib/a11y/lint/configuration.rb` — loads `.a11y-lint.yml` to enable/disable individual rules; searches upward from the target path
- **Rules:** `lib/a11y/lint/rules/` — rules implement `check(node)` against the shared node interface (`tag_name`, `attribute?`, `attributes`, `ruby_code`, `line`)
- **Version:** `lib/a11y/lint/version.rb`
- **Type signatures (RBS):** `sig/a11y/lint.rbs`
- **Tests:** `test/` directory using Minitest; test helper at `test/test_helper.rb`
- **Dummy app:** `test/fixtures/dummy_app/` — a fixture app with Slim/ERB templates for end-to-end smoke testing before releases (`bundle exec a11y-lint test/fixtures/dummy_app`)

## Code Style

RuboCop is configured in `.rubocop.yml`:
- Target Ruby version: 3.1
- Enforces double quotes for strings
