# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleNamePhlex < Minitest::Test
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

        def test_button_tag_with_block_image_tag_non_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  image_tag("home.svg", alt: "Home")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_image_tag_alt_no_parens_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag class: "button-icon" do
                  image_tag "home.svg", alt: "Home"
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_button_tag_with_block_image_tag_non_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(
                  class: "button-icon",
                  type: "button",
                ) do
                  image_tag("home.svg", alt: "Home")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_image_tag_dynamic_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  image_tag("home.svg", alt: @title)
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_image_tag_empty_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  image_tag("home.svg", alt: "")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_tag_with_block_image_tag_no_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  image_tag("home.svg")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

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

        def test_hidden_wrapper_with_icon_passes_by_default
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  span(class: "popover") { plain "Move" }
                  inline_svg("thumbs-up.svg")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_hidden_wrapper_with_icon_reports_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button_tag(class: "button-icon") do
                  span(class: "popover") { plain "Move" }
                  inline_svg("thumbs-up.svg")
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
          assert_equal("ButtonTagMissingAccessibleName", offenses[0].rule)
        end

        private

        def offense_message
          "button_tag missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(
          source, filename: "test_view.rb", configuration: Configuration.new
        )
          PhlexRunner
            .new([ButtonTagMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
