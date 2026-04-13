# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestListInvalidChildrenSlim < Minitest::Test
        def test_ul_with_only_li_passes
          source = <<~SLIM.chomp
            ul
              li one
              li two
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ol_with_only_li_passes
          source = <<~SLIM.chomp
            ol
              li one
              li two
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ul_with_div_child_reports_offense
          source = <<~SLIM.chomp
            ul
              div bad
              li ok
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "<ul> must only directly contain <li>, <script>, " \
              "or <template> elements, found <div> (WCAG 1.3.1)",
            offenses[0].message
          )
          assert_equal("ListInvalidChildren", offenses[0].rule)
          assert_equal(1, offenses[0].line)
        end

        def test_ol_with_span_child_reports_offense
          source = <<~SLIM.chomp
            ol
              span bad
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "<ol> must only directly contain <li>, <script>, " \
              "or <template> elements, found <span> (WCAG 1.3.1)",
            offenses[0].message
          )
        end

        def test_ul_with_script_and_template_passes
          source = <<~SLIM.chomp
            ul
              li one
              script src="x.js"
              template
                li templated
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ul_with_li_inside_control_flow_passes
          source = <<~SLIM.chomp
            ul
              - items.each do |item|
                li= item
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ul_with_div_inside_control_flow_reports_offense
          source = <<~SLIM.chomp
            ul
              - items.each do |item|
                div= item
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "<ul> must only directly contain <li>, <script>, " \
              "or <template> elements, found <div> (WCAG 1.3.1)",
            offenses[0].message
          )
        end

        def test_ul_with_ruby_output_child_is_skipped
          source = <<~SLIM.chomp
            ul
              = render "items"
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_text_content_inside_ul_is_ignored
          source = <<~SLIM.chomp
            ul
              | whitespace
              li ok
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_ul_inside_li_passes
          source = <<~SLIM.chomp
            ul
              li
                ul
                  li nested
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_unrelated_div_with_div_children_passes
          source = <<~SLIM.chomp
            div
              div one
              span two
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner.new([ListInvalidChildren]).run(
            source, filename: filename
          )
        end
      end
    end
  end
end
