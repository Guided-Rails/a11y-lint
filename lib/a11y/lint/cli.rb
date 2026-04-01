# frozen_string_literal: true

require "optparse"

module A11y
  module Lint
    # Command-line interface for running accessibility linting on Slim templates.
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
          @stderr.puts("No .slim or .erb files found")
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
          Dir.glob(File.join(path, "**", "*.{slim,erb}"))
        elsif File.file?(path)
          [path]
        else
          @stderr.puts("Warning: #{path} not found, skipping")
          []
        end
      end

      def lint_files(files)
        rules = all_rules
        slim_runner = SlimRunner.new(rules)
        erb_runner = ErbRunner.new(rules)

        files.flat_map do |file|
          source = File.read(file)
          runner = file.end_with?(".erb") ? erb_runner : slim_runner
          runner.run(source, filename: file)
        end
      end

      def all_rules
        configuration = Configuration.load(@config_path, search_path: @argv.first || ".")

        Rules.constants.filter_map do |name|
          klass = Rules.const_get(name)
          next unless klass.is_a?(Class) && klass < Rule

          rule = klass.new
          rule if configuration.enabled?(rule.name)
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
