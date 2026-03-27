# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestOffense < Minitest::Test
      def test_rule
        rule = "ImgMissingAlt"

        offense = Offense.new(rule:, filename: "x", line: 0, message: "x")

        assert_equal(rule, offense.rule)
      end

      def test_filename
        filename = "app/views/index.html.slim"

        offense = Offense.new(rule: "x", filename:, line: 0, message: "x")

        assert_equal(filename, offense.filename)
      end

      def test_line
        line = 5

        offense = Offense.new(rule: "x", filename: "x", line:, message: "x")

        assert_equal(line, offense.line)
      end

      def test_message
        message = "img tag is missing an alt attribute (WCAG 1.1.1)"

        offense = Offense.new(rule: "x", filename: "x", line: 0, message:)

        assert_equal(message, offense.message)
      end
    end
  end
end
