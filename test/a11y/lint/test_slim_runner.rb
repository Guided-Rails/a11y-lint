# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestSlimRunner < Minitest::Test
      def test_for_clean_source
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run('img src="photo.jpg" alt="A photo"', filename: "test.slim")

        assert_empty(offenses)
      end

      def test_for_violations
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run('img src="photo.jpg"', filename: "test.slim")

        assert_equal(1, offenses.length)
      end

      def test_rrule_name
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run('img src="photo.jpg"', filename: "test.slim")

        assert_equal("ImgMissingAlt", offenses[0].rule)
      end

      def test_filename
        filename = "app/views/show.slim"
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run('img src="photo.jpg"', filename:)

        assert_equal(filename, offenses[0].filename)
      end

      def test_line_number
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run("div\n  img src=\"photo.jpg\"", filename: "test.slim")

        assert_equal(2, offenses[0].line)
      end

      def test_message
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run('img src="photo.jpg"', filename: "test.slim")

        assert_equal(
          "img tag is missing an alt attribute (WCAG 1.1.1)",
          offenses[0].message
        )
      end

      def test_line_numbers_across_multiple_elements
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run(multiline_source, filename: "test.slim")

        assert_equal(2, offenses.length)
        assert_equal(3, offenses[0].line)
        assert_equal(5, offenses[1].line)
      end

      def test_non_tag_elements
        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run("| Plain text content", filename: "test.slim")

        assert_empty(offenses)
      end

      def test_slim_output_nodes
        offenses =
          SlimRunner
          .new([Rules::ImageTagMissingAlt])
          .run('= image_tag "photo.jpg"', filename: "test.slim")

        assert_equal(1, offenses.length)
      end

      def test_line_number_after_multiline_output
        source = <<~SLIM.chomp
          = link_to(\\
            "",
            "/path",
          )
          img src="photo.jpg"
        SLIM

        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run(source, filename: "test.slim")

        assert_equal(1, offenses.length)
        assert_equal(5, offenses[0].line)
      end

      def test_line_number_after_multiline_control
        source = <<~SLIM.chomp
          - x = foo(\\
            bar,
            baz,
          )
          img src="photo.jpg"
        SLIM

        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run(source, filename: "test.slim")

        assert_equal(1, offenses.length)
        assert_equal(5, offenses[0].line)
      end

      def test_raises_slim_load_error_when_slim_is_not_installed
        runner = SlimRunner.new([Rules::ImgMissingAlt])

        fake_require = lambda { |name|
          raise LoadError if name == "slim"
        }

        runner.stub(:require, fake_require) do
          assert_raises(SlimLoadError) do
            runner.run('img src="photo.jpg"', filename: "test.slim")
          end
        end
      end

      def test_line_number_after_multiple_multiline_expressions
        source = <<~SLIM.chomp
          = form_for(\\
            @user,
            url: path,
          ) do |f|
            = f.input(\\
              :name,
              required: true,
            )
            img src="photo.jpg"
        SLIM

        offenses =
          SlimRunner
          .new([Rules::ImgMissingAlt])
          .run(source, filename: "test.slim")

        assert_equal(1, offenses.length)
        assert_equal(9, offenses[0].line)
      end

      private

      def multiline_source
        <<~SLIM.chomp
          div
            p Hello
            img src="a.jpg"
            span World
            img src="b.jpg"
        SLIM
      end
    end
  end
end
