# frozen_string_literal: true

require "optparse"

module A11y
  module Lint
    # Command-line interface for running accessibility linting.
    class CLI
      def initialize(argv, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
        @config_path = nil
      end

      def run
        parse_options!
        files = resolve_files(@argv)

        if files.empty?
          @stderr.puts("No .slim, .erb, or .rb files found")
          return 0
        end

        offenses = lint_files(files)
        print_results(offenses)

        offenses.empty? ? 0 : 1
      end

      private

      def parse_options!
        option_parser.parse!(@argv)
      end

      def option_parser # rubocop:disable Metrics/MethodLength
        OptionParser.new do |opts|
          opts.banner = "Usage: a11y-lint [options] [file_or_directory ...]"

          opts.on("-v", "--version", "Show version") do
            @stdout.puts(A11y::Lint::VERSION)
            exit 0
          end

          opts.on("-c", "--config PATH", "Path to configuration file") do |path|
            @config_path = path
          end

          opts.on("-h", "--help", "Show help") do
            @stdout.puts(opts)
            exit 0
          end
        end
      end

      def resolve_files(paths)
        paths = ["."] if paths.empty?
        paths.flat_map { |path| expand_path(path) }.sort
      end

      def expand_path(path)
        if File.directory?(path)
          Dir.glob(File.join(path, "**", "*.{slim,erb,rb}"))
        elsif File.file?(path)
          [path]
        else
          @stderr.puts("Warning: #{path} not found, skipping")
          []
        end
      end

      def lint_files(files)
        configuration = load_configuration
        rules = rules_for(configuration)
        slim_runner = SlimRunner.new(rules, configuration: configuration)
        erb_runner = ErbRunner.new(rules, configuration: configuration)
        phlex_runner = PhlexRunner.new(rules, configuration: configuration)

        files.flat_map do |file|
          source = File.read(file)
          runner = runner_for(file, slim_runner, erb_runner, phlex_runner)
          runner.run(source, filename: file)
        end
      end

      def runner_for(file, slim_runner, erb_runner, phlex_runner)
        case File.extname(file)
        when ".erb" then erb_runner
        when ".rb" then phlex_runner
        else slim_runner
        end
      end

      def load_configuration
        Configuration.load(@config_path, search_path: @argv.first || ".")
      end

      def rules_for(configuration)
        Rules.constants.filter_map do |name|
          klass = Rules.const_get(name)
          next unless klass.is_a?(Class) && klass < NodeRule

          klass if configuration.enabled?(klass.rule_name)
        end
      end

      def print_results(offenses)
        offenses.each { |offense| print_offense(offense) }
        @stdout.puts(summary_message(offenses.length))
      end

      def print_offense(offense)
        @stdout.puts(
          "#{offense.filename}:#{offense.line} " \
          "[#{offense.rule}] #{offense.message}"
        )
      end

      def summary_message(count)
        return "No offenses found" if count.zero?

        "#{count} offense#{"s" unless count == 1} found"
      end
    end
  end
end
