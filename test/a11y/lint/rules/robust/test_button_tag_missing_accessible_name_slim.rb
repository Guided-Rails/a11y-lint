# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleNameSlim < Minitest::Test
        # = button_tag("", class: "icon")
        def test_button_tag_with_empty_text_reports_offense
          source = <<~SLIM.chomp
            = button_tag("", class: "icon")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal(
            "ButtonTagMissingAccessibleName",
            offenses[0].rule
          )
        end

        # = button_tag "", class: "icon"
        def test_button_tag_with_empty_text_without_parens_reports_offense
          source = <<~SLIM.chomp
            = button_tag "", class: "icon"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = button_tag(\
        #     "",
        #     class: "icon",
        #   )
        def test_multiline_button_tag_with_trailing_comma_reports_offense
          source = <<~SLIM.chomp
            = button_tag(\\
                "",
                class: "icon",
              )
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = button_tag("Submit")
        def test_button_tag_with_text_passes
          source = <<~SLIM.chomp
            = button_tag("Submit")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag("", class: "icon", aria: { label: "Submit" })
        def test_button_tag_with_aria_hash_label_passes
          source = <<~SLIM.chomp
            = button_tag("", class: "icon", aria: { label: "Submit" })
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag "", class: "icon", aria: { label: "Submit" }
        def test_button_tag_without_parens_and_aria_label_passes
          source = <<~SLIM.chomp
            = button_tag "", class: "icon", aria: { label: "Submit" }
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag(\
        #     "",
        #     class: "icon",
        #     aria: { label: "Submit" },
        #   )
        def test_multiline_button_tag_with_trailing_comma_and_aria_label_passes
          source = <<~SLIM.chomp
            = button_tag(\\
                "",
                class: "icon",
                aria: { label: "Submit" },
              )
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag("", class: "icon", "aria-label" => "Submit")
        def test_button_tag_with_string_aria_label_passes
          source = <<~SLIM.chomp
            = button_tag("", class: "icon", "aria-label" => "Submit")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag(class: "button-icon") do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_reports_offense
          source = <<~SLIM.chomp
            = button_tag(class: "button-icon") do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal(
            "ButtonTagMissingAccessibleName",
            offenses[0].rule
          )
        end

        # = button_tag(class: "button-icon", aria: { label: "Menu" }) do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_and_aria_label_passes
          source = <<~SLIM.chomp
            = button_tag(class: "button-icon", aria: { label: "Menu" }) do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag class: "button-icon" do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_without_parens_reports_offense
          source = <<~SLIM.chomp
            = button_tag class: "button-icon" do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = button_tag class: "button-icon", aria: { label: "Menu" } do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_without_parens_and_aria_label_passes
          source = <<~SLIM.chomp
            = button_tag class: "button-icon", aria: { label: "Menu" } do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag(\
        #     class: "button-icon",
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_button_tag_with_block_reports_offense
          source = <<~SLIM.chomp
            = button_tag(\\
                class: "button-icon",
              ) do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = button_tag(\
        #     class: "button-icon",
        #     aria: { label: "Menu" },
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_button_tag_with_block_and_aria_label_passes
          source = <<~SLIM.chomp
            = button_tag(\\
                class: "button-icon",
                aria: { label: "Menu" },
              ) do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag(class: "button-icon") do
        #   = inline_svg("icon.svg")
        #   = t(".label")
        def test_button_tag_with_block_and_text_passes
          source = <<~SLIM.chomp
            = button_tag(class: "button-icon") do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag class: "button-icon" do
        #   = inline_svg("icon.svg")
        #   = t(".label")
        def test_button_tag_with_block_without_parens_and_text_passes
          source = <<~SLIM.chomp
            = button_tag class: "button-icon" do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = button_tag(\
        #     class: "button-icon",
        #   ) do
        #   = inline_svg("icon.svg")
        #   = t(".label")
        def test_multiline_button_tag_with_block_and_text_passes
          source = <<~SLIM.chomp
            = button_tag(\\
                class: "button-icon",
              ) do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def offense_message
          "button_tag missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(source, filename: "test.slim")
          SlimRunner
            .new([ButtonTagMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
