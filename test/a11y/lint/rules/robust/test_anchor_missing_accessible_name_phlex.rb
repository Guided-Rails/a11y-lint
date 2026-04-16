# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestAnchorMissingAccessibleNamePhlex < Minitest::Test
        def test_empty_anchor_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "a tag is missing an accessible name " \
              "requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("AnchorMissingAccessibleName", offenses[0].rule)
        end

        def test_anchor_with_only_img_no_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { img(src: "icon.svg") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_only_img_empty_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { img(src: "icon.svg", alt: "") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_text_content_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { plain "Home" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_child_tag_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") do
                  span { plain "Home" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path", aria_label: "Home")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_string_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path", "aria-label": "Home")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_img_with_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { img(src: "home.svg", alt: "Home") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_anchor
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  a(href: "/path")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_anchors_reports_only_missing
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/home") { plain "Home" }
                a(href: "/profile")
                a(href: "/settings", aria_label: "Settings")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_deeply_nested_empty_anchor
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                section do
                  div do
                    nav do
                      a(href: "/path")
                    end
                  end
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(6, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner
            .new([AnchorMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
