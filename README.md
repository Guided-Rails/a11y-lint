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

With no arguments, it scans the current directory recursively for `.slim`, `.erb`, and `.rb` (Phlex) files:

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

### Ruby API

```ruby
require "a11y/lint"

# Slim
source = File.read("app/views/home.html.slim")
runner = A11y::Lint::SlimRunner.new([A11y::Lint::Rules::ImgMissingAlt])
offenses = runner.run(source, filename: "app/views/home.html.slim")

# ERB
source = File.read("app/views/home.html.erb")
runner = A11y::Lint::ErbRunner.new([A11y::Lint::Rules::ImgMissingAlt])
offenses = runner.run(source, filename: "app/views/home.html.erb")

# Phlex
source = File.read("app/views/home_view.rb")
runner = A11y::Lint::PhlexRunner.new([A11y::Lint::Rules::ImgMissingAlt])
offenses = runner.run(source, filename: "app/views/home_view.rb")

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
