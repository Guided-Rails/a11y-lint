# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestMissingAccessibleNameSlim < Minitest::Test
        # = link_to("", "/path", class: "icon")
        def test_link_to_with_empty_text_reports_offense
          offenses = run_fixture("link_to_empty_text")

          assert_equal(1, offenses.length)
          assert_equal(offense_message("link_to"), offenses[0].message)
          assert_equal(1, offenses[0].line)
          assert_equal("MissingAccessibleName", offenses[0].rule)
        end

        # = external_link_to("", "https://example.com", class: "icon")
        def test_external_link_to_with_empty_text_reports_offense
          offenses = run_fixture("external_link_to_empty_text")

          assert_equal(1, offenses.length)
          assert_equal(offense_message("external_link_to"), offenses[0].message)
        end

        # = external_link_to "", "https://example.com", class: "icon"
        def test_link_to_with_empty_text_without_parens_reports_offense
          offenses = run_fixture("external_link_to_empty_text_no_parens")

          assert_equal(1, offenses.length)
        end

        # = link_to "", "/path", aria: { label: "Facebook" }
        def test_link_to_without_parens_and_aria_label_passes
          offenses = run_fixture("link_to_no_parens_aria_label")

          assert_empty(offenses)
        end

        # = link_to("Click here", "/path")
        def test_link_to_with_text_passes
          offenses = run_fixture("link_to_with_text")

          assert_empty(offenses)
        end

        # = link_to("", "/path", aria: { label: "Facebook" })
        def test_link_to_with_aria_hash_label_passes
          offenses = run_fixture("link_to_aria_hash_label")

          assert_empty(offenses)
        end

        # = link_to("", "/path", "aria-label" => "Facebook")
        def test_link_to_with_string_aria_label_passes
          offenses = run_fixture("link_to_string_aria_label")

          assert_empty(offenses)
        end

        # = link_to("", "/path", aria: { describedby: "desc" })
        def test_link_to_with_aria_hash_without_label_reports_offense
          offenses = run_fixture("link_to_aria_hash_without_label")

          assert_equal(1, offenses.length)
        end

        # div
        #   = link_to("", "/path")
        def test_nested_link_to_with_empty_text
          offenses = run_fixture("link_to_nested")

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        # = submit_tag("", "/path")
        def test_non_matching_method_is_ignored
          offenses = run_fixture("submit_tag")

          assert_empty(offenses)
        end

        # = link_to(\
        #     "",
        #     "/path",
        #     class: "icon",
        #   )
        def test_multiline_link_to_with_trailing_comma_reports_offense
          offenses = run_fixture("link_to_multiline")

          assert_equal(1, offenses.length)
        end

        # = link_to(\
        #     "",
        #     "/path",
        #     aria: { label: "Facebook" },
        #   )
        def test_multiline_link_to_with_trailing_comma_and_aria_label_passes
          offenses = run_fixture("link_to_multiline_aria_label")

          assert_empty(offenses)
        end

        # = link_to("#", class: "icon") do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_reports_offense
          offenses = run_fixture("link_to_block")

          assert_equal(1, offenses.length)
          assert_equal(offense_message("link_to"), offenses[0].message)
          assert_equal(1, offenses[0].line)
          assert_equal("MissingAccessibleName", offenses[0].rule)
        end

        # = link_to("#", class: "icon", aria: { label: "Icon" }) do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_and_aria_label_passes
          offenses = run_fixture("link_to_block_aria_label")

          assert_empty(offenses)
        end

        # = link_to "#", class: "icon" do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_without_parens_reports_offense
          offenses = run_fixture("link_to_block_no_parens")

          assert_equal(1, offenses.length)
        end

        # = link_to "#", class: "icon", aria: { label: "Icon" } do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_without_parens_and_aria_label_passes
          offenses = run_fixture("link_to_block_no_parens_aria_label")

          assert_empty(offenses)
        end

        # = link_to(\
        #     "#",
        #     class: "icon",
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_link_to_with_block_reports_offense
          offenses = run_fixture("link_to_multiline_block")

          assert_equal(1, offenses.length)
        end

        # = link_to(\
        #     "#",
        #     class: "icon",
        #     aria: { label: "Icon" },
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_link_to_with_block_and_aria_label_passes
          offenses = run_fixture("link_to_multiline_block_aria_label")

          assert_empty(offenses)
        end

        # = external_link_to("https://example.com", class: "icon") do
        #   = inline_svg("icon.svg")
        def test_external_link_to_with_block_reports_offense
          offenses = run_fixture("external_link_to_block")

          assert_equal(1, offenses.length)
        end

        # = button_tag("", class: "icon")
        def test_button_tag_with_empty_text_reports_offense
          offenses = run_fixture("button_tag_empty_text")

          assert_equal(1, offenses.length)
          assert_equal(offense_message("button_tag"), offenses[0].message)
          assert_equal("MissingAccessibleName", offenses[0].rule)
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
          assert_equal(offense_message("button_tag"), offenses[0].message)
          assert_equal("MissingAccessibleName", offenses[0].rule)
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

        # = link_to("", "/path")
        def test_sets_filename_on_offense
          offenses = run_fixture(
            "link_to_sets_filename",
            filename: "app/views/index.html.slim"
          )

          assert_equal("app/views/index.html.slim", offenses[0].filename)
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

        # = link_to("#", class: "icon") do
        #   = inline_svg("icon.svg")
        #   = t(".label")
        def test_link_to_with_block_and_text_passes
          source = <<~SLIM.chomp
            = link_to("#", class: "icon") do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_source(source)

          assert_empty(offenses)
        end

        # = link_to "#", class: "icon" do
        #   = inline_svg("icon.svg")
        #   = t(".label")
        def test_link_to_with_block_without_parens_and_text_passes
          source = <<~SLIM.chomp
            = link_to "#", class: "icon" do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_source(source)

          assert_empty(offenses)
        end

        # = link_to(\
        #     "#",
        #     class: "icon",
        #   ) do
        #   = inline_svg("icon.svg")
        #   = t(".label")
        def test_multiline_link_to_with_block_and_text_passes
          source = <<~SLIM.chomp
            = link_to(\
                "#",
                class: "icon",
              ) do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_source(source)

          assert_empty(offenses)
        end

        private

        def offense_message(method_name)
          "#{method_name} missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_fixture(name, filename: "test.slim")
          source = file_fixture("missing_accessible_name/slim/#{name}.slim")
          SlimRunner.new([MissingAccessibleName]).run(source, filename:)
        end

        def run_source(source, filename: "test.slim")
          SlimRunner.new([MissingAccessibleName]).run(source, filename:)
        end
      end
    end
  end
end
