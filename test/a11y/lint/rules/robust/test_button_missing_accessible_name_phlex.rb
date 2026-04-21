# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonMissingAccessibleNamePhlex < Minitest::Test
        def test_empty_button_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "button tag is missing an accessible name " \
              "requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("ButtonMissingAccessibleName", offenses[0].rule)
        end

        def test_button_with_only_img_no_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") { img(src: "icon.svg") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_only_img_empty_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") { img(src: "icon.svg", alt: "") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_text_content_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { plain "Submit" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_child_tag_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") do
                  span { plain "Submit" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button", aria_label: "Close")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_string_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button", "aria-label": "Close")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_img_with_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") { img(src: "close.svg", alt: "Close") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_button
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  button(type: "button")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_buttons_reports_only_missing
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { plain "Submit" }
                button(type: "button")
                button(type: "button", aria_label: "Close")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_deeply_nested_empty_button
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                section do
                  div do
                    form do
                      button(type: "submit")
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
                button(type: "button")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        def test_button_with_hidden_wrapper_text_passes_by_default
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") do
                  span(class: "popover") { plain "Move" }
                  img(src: "thumbs-up.svg")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_hidden_wrapper_text_reports_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") do
                  span(class: "popover") { plain "Move" }
                  img(src: "thumbs-up.svg")
                end
              end
            end
          RUBY

          offenses = run_linter(
            source,
            configuration: Configuration.new(
              "hidden_wrapper_classes" => ["popover"]
            )
          )

          assert_equal(1, offenses.length)
          assert_equal("ButtonMissingAccessibleName", offenses[0].rule)
        end

        private

        def run_linter(
          source, filename: "test_view.rb",
          configuration: Configuration.new
        )
          PhlexRunner
            .new([ButtonMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
