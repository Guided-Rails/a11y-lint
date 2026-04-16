# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleNameSlim < Minitest::Test
        # = button_tag("", class: "icon")
        def test_button_tag_with_empty_text_reports_offense
          offenses = run_fixture("button_tag_empty_text")

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal("ButtonTagMissingAccessibleName", offenses[0].rule)
        end

        # = button_tag "", class: "icon"
        def test_button_tag_with_empty_text_without_parens_reports_offense
          offenses = run_fixture("button_tag_empty_text_no_parens")

          assert_equal(1, offenses.length)
        end

        # = button_tag(\
        #     "",
        #     class: "icon",
        #   )
        def test_multiline_button_tag_with_trailing_comma_reports_offense
          offenses = run_fixture("button_tag_multiline")

          assert_equal(1, offenses.length)
        end

        # = button_tag("Submit")
        def test_button_tag_with_text_passes
          offenses = run_fixture("button_tag_with_text")

          assert_empty(offenses)
        end

        # = button_tag("", class: "icon", aria: { label: "Submit" })
        def test_button_tag_with_aria_hash_label_passes
          offenses = run_fixture("button_tag_aria_hash_label")

          assert_empty(offenses)
        end

        # = button_tag "", class: "icon", aria: { label: "Submit" }
        def test_button_tag_without_parens_and_aria_label_passes
          offenses = run_fixture("button_tag_no_parens_aria_label")

          assert_empty(offenses)
        end

        # = button_tag(\
        #     "",
        #     class: "icon",
        #     aria: { label: "Submit" },
        #   )
        def test_multiline_button_tag_with_trailing_comma_and_aria_label_passes
          offenses = run_fixture("button_tag_multiline_aria_label")

          assert_empty(offenses)
        end

        # = button_tag("", class: "icon", "aria-label" => "Submit")
        def test_button_tag_with_string_aria_label_passes
          offenses = run_fixture("button_tag_string_aria_label")

          assert_empty(offenses)
        end

        # = button_tag(class: "button-icon") do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_reports_offense
          offenses = run_fixture("button_tag_block")

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal("ButtonTagMissingAccessibleName", offenses[0].rule)
        end

        # = button_tag(class: "button-icon", aria: { label: "Menu" }) do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_and_aria_label_passes
          offenses = run_fixture("button_tag_block_aria_label")

          assert_empty(offenses)
        end

        # = button_tag class: "button-icon" do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_without_parens_reports_offense
          offenses = run_fixture("button_tag_block_no_parens")

          assert_equal(1, offenses.length)
        end

        # = button_tag class: "button-icon", aria: { label: "Menu" } do
        #   = inline_svg("icon.svg")
        def test_button_tag_with_block_without_parens_and_aria_label_passes
          offenses = run_fixture("button_tag_block_no_parens_aria_label")

          assert_empty(offenses)
        end

        # = button_tag(\
        #     class: "button-icon",
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_button_tag_with_block_reports_offense
          offenses = run_fixture("button_tag_multiline_block")

          assert_equal(1, offenses.length)
        end

        # = button_tag(\
        #     class: "button-icon",
        #     aria: { label: "Menu" },
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_button_tag_with_block_and_aria_label_passes
          offenses = run_fixture("button_tag_multiline_block_aria_label")

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

          offenses = run_source(source)

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

          offenses = run_source(source)

          assert_empty(offenses)
        end

        # = button_tag(\
        #     class: "button-icon",
        #   ) do
        #   = inline_svg("icon.svg")
        #   = t(".label")
        def test_multiline_button_tag_with_block_and_text_passes
          source = <<~SLIM.chomp
            = button_tag(\
                class: "button-icon",
              ) do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_source(source)

          assert_empty(offenses)
        end

        private

        def offense_message
          "button_tag missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_fixture(name, filename: "test.slim")
          source = file_fixture(
            "button_tag_missing_accessible_name/slim/#{name}.slim"
          )
          SlimRunner
            .new([ButtonTagMissingAccessibleName])
            .run(source, filename:)
        end

        def run_source(source, filename: "test.slim")
          SlimRunner
            .new([ButtonTagMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
