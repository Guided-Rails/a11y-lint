# frozen_string_literal: true

require "test_helper"
require "a11y/lint/cli"
require "stringio"
require "tmpdir"
require "fileutils"

module A11y
  module Lint
    class TestCLIErb < Minitest::Test
      def test_erb_clean_file
        Dir.mktmpdir do |dir|
          write_file(
            dir,
            "clean.html.erb",
            '<img src="photo.jpg" alt="A photo">'
          )

          stdout, _stderr = run_cli([dir])

          assert_equal(0, @exit_code)
          assert_match(/No offenses found/, stdout)
        end
      end

      def test_erb_file_with_offense
        Dir.mktmpdir do |dir|
          write_file(dir, "bad.html.erb", '<img src="photo.jpg">')

          stdout, _stderr = run_cli([dir])

          assert_equal(1, @exit_code)
          assert_match(/\[ImgMissingAlt\]/, stdout)
          assert_match(/1 offense found/, stdout)
        end
      end

      def test_erb_recursive_directory_scan
        Dir.mktmpdir do |dir|
          subdir = File.join(dir, "views", "admin")
          FileUtils.mkdir_p(subdir)
          write_file(subdir, "index.html.erb", '<img src="photo.jpg">')

          stdout, _stderr = run_cli([dir])

          assert_equal(1, @exit_code)
          assert_match(/\[ImgMissingAlt\]/, stdout)
        end
      end

      def test_mixed_slim_and_erb
        Dir.mktmpdir do |dir|
          write_file(dir, "bad.slim", 'img src="photo.jpg"')
          write_file(dir, "bad.html.erb", '<img src="photo.jpg">')

          stdout, _stderr = run_cli([dir])

          assert_equal(1, @exit_code)
          assert_match(/2 offenses found/, stdout)
        end
      end

      def test_explicit_erb_file_argument
        Dir.mktmpdir do |dir|
          path = write_file(dir, "specific.html.erb", '<img src="photo.jpg">')

          stdout, _stderr = run_cli([path])

          assert_equal(1, @exit_code)
          assert_match(/specific\.html\.erb/, stdout)
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
