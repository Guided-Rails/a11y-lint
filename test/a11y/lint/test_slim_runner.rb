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

      def test_template_rules_receive_collected_nodes
        received_nodes = nil
        template_rule = make_template_rule do |nodes|
          received_nodes = nodes
          []
        end

        SlimRunner
          .new([], template_rules: [template_rule])
          .run("div\n  img src=\"photo.jpg\"", filename: "test.slim")

        assert_instance_of(Array, received_nodes)
        tag_names = received_nodes.map(&:tag_name).compact
        assert_includes(tag_names, "div")
        assert_includes(tag_names, "img")
      end

      def test_template_rule_offenses_included_in_results
        offense = Offense.new(
          rule: "TestRule",
          filename: "test.slim",
          line: 1,
          message: "test offense"
        )
        template_rule = make_template_rule { |_| [offense] }

        offenses =
          SlimRunner
          .new([], template_rules: [template_rule])
          .run("div", filename: "test.slim")

        assert_includes(offenses, offense)
      end

      private

      def make_template_rule(&block)
        rule = TemplateRule.new
        rule.define_singleton_method(:check_template) do |filename:, nodes:| # rubocop:disable Lint/UnusedBlockArgument
          block.call(nodes)
        end
        rule
      end

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
