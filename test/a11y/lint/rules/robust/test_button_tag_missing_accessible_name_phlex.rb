# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleNamePhlex < Minitest::Test
        # button_tag("", class: "icon")
        def test_button_tag_with_empty_text_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag("", class: "icon")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal("ButtonTagMissingAccessibleName", offenses[0].rule)
        end

        # button_tag("Submit")
        def test_button_tag_with_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag("Submit")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # button_tag("", class: "icon", aria: { label: "Submit" })
        def test_button_tag_with_aria_hash_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag("", class: "icon", aria: { label: "Submit" })
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # button_tag("", class: "icon", "aria-label" => "Submit")
        def test_button_tag_with_string_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag("", class: "icon", "aria-label" => "Submit")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # button_tag(class: "button-icon") do
        #   span(class: "icon-menu")
        # end
        def test_button_tag_with_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  span(class: "icon-menu")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
        end

        # button_tag(class: "button-icon", aria: { label: "Menu" }) do
        #   span(class: "icon-menu")
        # end
        def test_button_tag_with_block_and_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon", aria: { label: "Menu" }) do
                  span(class: "icon-menu")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # button_tag(class: "button-icon") do
        #   inline_svg("icon.svg")
        #   span { t(".label") }
        # end
        def test_button_tag_with_block_and_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  inline_svg("icon.svg")
                  span { t(".label") }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def offense_message
          "button_tag missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner
            .new([ButtonTagMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
