# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestListInvalidChildrenPhlex < Minitest::Test
        def test_ul_with_only_li_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                ul do
                  li { "one" }
                  li { "two" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ol_with_only_li_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                ol do
                  li { "one" }
                  li { "two" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_ul_with_div_child_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                ul do
                  div { "bad" }
                  li { "ok" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "<ul> must only directly contain <li>, <script>, " \
              "or <template> elements, found <div> (WCAG 1.3.1)",
            offenses[0].message
          )
          assert_equal("ListInvalidChildren", offenses[0].rule)
          assert_equal(3, offenses[0].line)
        end

        def test_ol_with_span_child_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                ol do
                  span { "bad" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "<ol> must only directly contain <li>, <script>, " \
              "or <template> elements, found <span> (WCAG 1.3.1)",
            offenses[0].message
          )
        end

        def test_ul_with_script_and_template_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                ul do
                  li { "one" }
                  script(src: "x.js")
                  template_tag do
                    li { "templated" }
                  end
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_ul_inside_li_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                ul do
                  li do
                    ul do
                      li { "nested" }
                    end
                  end
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_unrelated_div_with_div_children_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  div { "one" }
                  span { "two" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_sets_filename_on_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                ul do
                  div { "bad" }
                end
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner.new([ListInvalidChildren]).run(
            source, filename: filename
          )
        end
      end
    end
  end
end
