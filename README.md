# A11y::Lint

A Ruby gem for checking accessibility issues in your code.

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "a11y-lint"
```

Then run:

```bash
bundle install
```

Or install it directly:

```bash
gem install a11y-lint
```

## Usage

### Command Line

Run the linter on specific files or directories:

```bash
a11y-lint app/views/
a11y-lint app/views/home.html.slim app/views/about.html.slim
```

With no arguments, it scans the current directory recursively for `.slim` and `.erb` files:

```bash
a11y-lint
```

### Configuration

Create a `.a11y-lint.yml` file in your project root to enable or disable individual rules:

```yaml
ImgMissingAlt:
  Enabled: false

ImageTagMissingAlt:
  Enabled: true
```

Rules not listed in the file are enabled by default. The linter searches for `.a11y-lint.yml` starting from the target directory and walking up to the filesystem root.

To specify a config file explicitly:

```bash
a11y-lint --config path/to/.a11y-lint.yml app/views/
```

### Rules

| Rule | WCAG | Description |
|------|------|-------------|
| `ImgMissingAlt` | 1.1.1 | `img` tags must have an `alt` attribute |
| `ImageTagMissingAlt` | 1.1.1 | `image_tag` calls must have an `alt` option |
| `MissingAccessibleName` | 4.1.2 | `link_to`, `external_link_to`, and `button_tag` with empty text must have an `aria-label` |
| `SkipNavigationLink` | 2.4.1 | Layout files must include a skip navigation link (`<a href="#...">`) |

### Ruby API

```ruby
require "a11y/lint"

source = File.read("app/views/home.html.slim")

node_rules = [A11y::Lint::Rules::ImgMissingAlt.new]
template_rules = [A11y::Lint::Rules::SkipNavigationLink.new]

runner = A11y::Lint::SlimRunner.new(node_rules, template_rules:)
offenses = runner.run(source, filename: "app/views/home.html.slim")

offenses.each do |offense|
  puts "#{offense.filename}:#{offense.line} [#{offense.rule}] #{offense.message}"
end
```

## Requirements

- Ruby >= 3.1.0

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run all checks (tests + linting):

```bash
bundle exec rake
```

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Guided-Rails/a11y-lint. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Guided-Rails/a11y-lint/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the A11y::Lint project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Guided-Rails/a11y-lint/blob/main/CODE_OF_CONDUCT.md).
