# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestRunner < Minitest::Test
      def test_for_clean_source
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run('img src="photo.jpg" alt="A photo"', filename: "test.slim")

        assert_empty(offenses)
      end

      def test_for_violations
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run('img src="photo.jpg"', filename: "test.slim")

        assert_equal(1, offenses.length)
      end

      def test_rrule_name
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run('img src="photo.jpg"', filename: "test.slim")

        assert_equal("ImgMissingAlt", offenses[0].rule)
      end

      def test_filename
        filename = "app/views/show.slim"
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run('img src="photo.jpg"', filename:)

        assert_equal(filename, offenses[0].filename)
      end

      def test_line_number
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run("div\n  img src=\"photo.jpg\"", filename: "test.slim")

        assert_equal(2, offenses[0].line)
      end

      def test_message
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run('img src="photo.jpg"', filename: "test.slim")

        assert_equal(
          "img tag is missing an alt attribute (WCAG 1.1.1)",
          offenses[0].message
        )
      end

      def test_line_numbers_across_multiple_elements
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run(multiline_source, filename: "test.slim")

        assert_equal(2, offenses.length)
        assert_equal(3, offenses[0].line)
        assert_equal(5, offenses[1].line)
      end

      def test_non_tag_elements
        offenses =
          Runner
          .new([Rules::ImgMissingAlt.new])
          .run("| Plain text content", filename: "test.slim")

        assert_empty(offenses)
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
