# frozen_string_literal: true

require "test_helper"
require "a11y/lint/cli"
require "stringio"
require "tmpdir"
require "fileutils"

module A11y
  module Lint
    class TestCLI < Minitest::Test
      def test_no_files_found
        Dir.mktmpdir do |dir|
          _stdout, stderr = run_cli([], dir:)

          assert_equal(0, @exit_code)
          assert_match(/No .slim files found/, stderr)
        end
      end

      def test_clean_file
        Dir.mktmpdir do |dir|
          write_slim(dir, "clean.slim", 'img src="photo.jpg" alt="A photo"')

          stdout, _stderr = run_cli([dir])

          assert_equal(0, @exit_code)
          assert_match(/No offenses found/, stdout)
        end
      end

      def test_file_with_offense
        Dir.mktmpdir do |dir|
          write_slim(dir, "bad.slim", 'img src="photo.jpg"')

          stdout, _stderr = run_cli([dir])

          assert_equal(1, @exit_code)
          assert_match(/\[ImgMissingAlt\]/, stdout)
          assert_match(/1 offense found/, stdout)
        end
      end

      def test_output_format
        Dir.mktmpdir do |dir|
          path = write_slim(dir, "bad.slim", 'img src="photo.jpg"')

          stdout, _stderr = run_cli([path])

          assert_match(
            /bad\.slim:1 \[ImgMissingAlt\] img tag is missing/,
            stdout
          )
        end
      end

      def test_multiple_offenses
        Dir.mktmpdir do |dir|
          write_slim(dir, "bad.slim", "img src=\"a.jpg\"\nimg src=\"b.jpg\"")

          stdout, _stderr = run_cli([dir])

          assert_equal(1, @exit_code)
          assert_match(/2 offenses found/, stdout)
        end
      end

      def test_default_scans_current_directory
        Dir.mktmpdir do |dir|
          write_slim(dir, "test.slim", 'img src="photo.jpg"')

          stdout, _stderr = run_cli([], dir:)

          assert_equal(1, @exit_code)
          assert_match(/\[ImgMissingAlt\]/, stdout)
        end
      end

      def test_recursive_directory_scan
        Dir.mktmpdir do |dir|
          subdir = File.join(dir, "views", "admin")
          FileUtils.mkdir_p(subdir)
          write_slim(subdir, "index.slim", 'img src="photo.jpg"')

          stdout, _stderr = run_cli([dir])

          assert_equal(1, @exit_code)
          assert_match(/\[ImgMissingAlt\]/, stdout)
        end
      end

      def test_version_flag
        stdout = StringIO.new

        assert_raises(SystemExit) do
          CLI.new(["--version"], stdout:).run
        end

        assert_match(/\d+\.\d+\.\d+/, stdout.string)
      end

      def test_nonexistent_path_warns
        _stdout, stderr = run_cli(["/nonexistent/path/file.slim"])

        assert_equal(0, @exit_code)
        assert_match(/not found, skipping/, stderr)
      end

      def test_explicit_file_argument
        Dir.mktmpdir do |dir|
          path = write_slim(dir, "specific.slim", 'img src="photo.jpg"')

          stdout, _stderr = run_cli([path])

          assert_equal(1, @exit_code)
          assert_match(/specific\.slim/, stdout)
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

      def write_slim(dir, name, content)
        path = File.join(dir, name)
        File.write(path, content)
        path
      end
    end
  end
end
