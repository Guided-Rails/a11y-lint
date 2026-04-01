# frozen_string_literal: true

require "test_helper"
require "a11y/lint/cli"
require "stringio"
require "tmpdir"

module A11y
  module Lint
    class TestCLIConfiguration < Minitest::Test
      def test_disabled_rule_is_not_reported
        Dir.mktmpdir do |dir|
          write_file(dir, "bad.slim", 'img src="photo.jpg"')
          config_path = write_file(dir, ".a11y-lint.yml", "ImgMissingAlt:\n  Enabled: false\n")

          stdout, _stderr = run_cli(["--config", config_path, dir])

          assert_equal(0, @exit_code)
          assert_match(/No offenses found/, stdout)
        end
      end

      def test_enabled_rule_is_still_reported
        Dir.mktmpdir do |dir|
          write_file(dir, "bad.slim", 'img src="photo.jpg"')
          config_path = write_file(dir, ".a11y-lint.yml", "ImgMissingAlt:\n  Enabled: true\n")

          stdout, _stderr = run_cli(["--config", config_path, dir])

          assert_equal(1, @exit_code)
          assert_match(/\[ImgMissingAlt\]/, stdout)
        end
      end

      def test_default_config_file_is_loaded_from_working_directory
        Dir.mktmpdir do |dir|
          write_file(dir, "bad.slim", 'img src="photo.jpg"')
          write_file(dir, ".a11y-lint.yml", "ImgMissingAlt:\n  Enabled: false\n")

          stdout, _stderr = run_cli([], dir:)

          assert_equal(0, @exit_code)
          assert_match(/No offenses found/, stdout)
        end
      end

      def test_other_rules_still_run_when_one_is_disabled
        Dir.mktmpdir do |dir|
          write_file(dir, "bad.slim", '= image_tag("photo.jpg")')
          config_path = write_file(dir, ".a11y-lint.yml", "ImgMissingAlt:\n  Enabled: false\n")

          stdout, _stderr = run_cli(["--config", config_path, dir])

          assert_equal(1, @exit_code)
          assert_match(/\[ImageTagMissingAlt\]/, stdout)
          refute_match(/\[ImgMissingAlt\]/, stdout)
        end
      end

      private

      def run_cli(args, dir: nil)
        stdout = StringIO.new
        stderr = StringIO.new

        original_dir = Dir.pwd
        Dir.chdir(dir) if dir

        @exit_code = CLI.new(args.dup, stdout:, stderr:).run

        [stdout.string, stderr.string]
      ensure
        Dir.chdir(original_dir) if dir
      end

      def write_file(dir, name, content)
        path = File.join(dir, name)
        File.write(path, content)
        path
      end
    end
  end
end
