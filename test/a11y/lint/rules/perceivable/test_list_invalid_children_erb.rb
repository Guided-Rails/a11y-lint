# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestListInvalidChildrenErb < Minitest::Test
        def test_ul_with_only_li_passes
          source = <<~ERB
            <ul>
              <li>one</li>
              <li>two</li>
            </ul>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ol_with_only_li_passes
          source = <<~ERB
            <ol>
              <li>one</li>
              <li>two</li>
            </ol>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ul_with_div_child_reports_offense
          source = <<~ERB
            <ul>
              <div>bad</div>
              <li>ok</li>
            </ul>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "<ul> must only directly contain <li>, <script>, " \
              "or <template> elements, found <div> (WCAG 1.3.1)",
            offenses[0].message
          )
          assert_equal("ListInvalidChildren", offenses[0].rule)
        end

        def test_ol_with_span_child_reports_offense
          source = <<~ERB
            <ol>
              <span>bad</span>
            </ol>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "<ol> must only directly contain <li>, <script>, " \
              "or <template> elements, found <span> (WCAG 1.3.1)",
            offenses[0].message
          )
        end

        def test_ul_with_script_passes
          source = <<~ERB
            <ul>
              <li>one</li>
              <script src="x.js"></script>
            </ul>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ul_with_erb_output_child_is_invisible
          source = <<~ERB
            <ul>
              <%= render "items" %>
            </ul>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ul_with_li_containing_erb_output_passes
          source = <<~ERB
            <ul>
              <% items.each do |item| %>
                <li><%= item %></li>
              <% end %>
            </ul>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_text_content_inside_ul_is_ignored
          source = <<~ERB
            <ul>
              text outside li
              <li>ok</li>
            </ul>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_ul_inside_li_passes
          source = <<~ERB
            <ul>
              <li>
                <ul>
                  <li>nested</li>
                </ul>
              </li>
            </ul>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_html_tags_mentioned_in_text_do_not_report_offense
          source = <<~ERB
            can only use these elements: <h1>, <div>, <br>, <ol>, <ul>, <li>, <em>, <strong>.
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_unrelated_div_with_div_children_passes
          source = <<~ERB
            <div>
              <div>one</div>
              <span>two</span>
            </div>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def run_linter(source, filename: "test.html.erb")
          ErbRunner.new([ListInvalidChildren]).run(
            source, filename: filename
          )
        end
      end
    end
  end
end
