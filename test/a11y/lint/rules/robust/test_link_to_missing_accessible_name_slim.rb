# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestLinkToMissingAccessibleNameSlim < Minitest::Test
        # = link_to("", "/path", class: "icon")
        def test_link_to_with_empty_text_reports_offense
          source = <<~SLIM.chomp
            = link_to("", "/path", class: "icon")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message("link_to"), offenses[0].message)
          assert_equal(1, offenses[0].line)
          assert_equal("LinkToMissingAccessibleName", offenses[0].rule)
        end

        # = external_link_to("", "https://example.com", class: "icon")
        def test_external_link_to_with_empty_text_reports_offense
          source = <<~SLIM.chomp
            = external_link_to("", "https://example.com", class: "icon")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("external_link_to"),
            offenses[0].message
          )
        end

        # = external_link_to "", "https://example.com", class: "icon"
        def test_link_to_with_empty_text_without_parens_reports_offense
          source = <<~SLIM.chomp
            = external_link_to "", "https://example.com", class: "icon"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = link_to "", "/path", aria: { label: "Facebook" }
        def test_link_to_without_parens_and_aria_label_passes
          source = <<~SLIM.chomp
            = link_to "", "/path", aria: { label: "Facebook" }
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to("Click here", "/path")
        def test_link_to_with_text_passes
          source = <<~SLIM.chomp
            = link_to("Click here", "/path")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to("", "/path", aria: { label: "Facebook" })
        def test_link_to_with_aria_hash_label_passes
          source = <<~SLIM.chomp
            = link_to("", "/path", aria: { label: "Facebook" })
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to("", "/path", "aria-label" => "Facebook")
        def test_link_to_with_string_aria_label_passes
          source = <<~SLIM.chomp
            = link_to("", "/path", "aria-label" => "Facebook")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to("", "/path", aria: { describedby: "desc" })
        def test_link_to_with_aria_hash_without_label_reports_offense
          source = <<~SLIM.chomp
            = link_to("", "/path", aria: { describedby: "desc" })
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # div
        #   = link_to("", "/path")
        def test_nested_link_to_with_empty_text
          source = <<~SLIM.chomp
            div
              = link_to("", "/path")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        # = submit_tag("", "/path")
        def test_non_matching_method_is_ignored
          source = <<~SLIM.chomp
            = submit_tag("", "/path")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to(\
        #     "",
        #     "/path",
        #     class: "icon",
        #   )
        def test_multiline_link_to_with_trailing_comma_reports_offense
          source = <<~SLIM.chomp
            = link_to(\\
                "",
                "/path",
                class: "icon",
              )
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = link_to(\
        #     "",
        #     "/path",
        #     aria: { label: "Facebook" },
        #   )
        def test_multiline_link_to_with_trailing_comma_and_aria_label_passes
          source = <<~SLIM.chomp
            = link_to(\\
                "",
                "/path",
                aria: { label: "Facebook" },
              )
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to("#", class: "icon") do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_reports_offense
          source = <<~SLIM.chomp
            = link_to("#", class: "icon") do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message("link_to"), offenses[0].message)
          assert_equal(1, offenses[0].line)
          assert_equal("LinkToMissingAccessibleName", offenses[0].rule)
        end

        # = link_to("#", class: "icon", aria: { label: "Icon" }) do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_and_aria_label_passes
          source = <<~SLIM.chomp
            = link_to("#", class: "icon", aria: { label: "Icon" }) do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to "#", class: "icon" do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_without_parens_reports_offense
          source = <<~SLIM.chomp
            = link_to "#", class: "icon" do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = link_to "#", class: "icon", aria: { label: "Icon" } do
        #   = inline_svg("icon.svg")
        def test_link_to_with_block_without_parens_and_aria_label_passes
          source = <<~SLIM.chomp
            = link_to "#", class: "icon", aria: { label: "Icon" } do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = link_to(\
        #     "#",
        #     class: "icon",
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_link_to_with_block_reports_offense
          source = <<~SLIM.chomp
            = link_to(\\
                "#",
                class: "icon",
              ) do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = link_to(\
        #     "#",
        #     class: "icon",
        #     aria: { label: "Icon" },
        #   ) do
        #   = inline_svg("icon.svg")
        def test_multiline_link_to_with_block_and_aria_label_passes
          source = <<~SLIM.chomp
            = link_to(\\
                "#",
                class: "icon",
                aria: { label: "Icon" },
              ) do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # = external_link_to("https://example.com", class: "icon") do
        #   = inline_svg("icon.svg")
        def test_external_link_to_with_block_reports_offense
          source = <<~SLIM.chomp
            = external_link_to("https://example.com", class: "icon") do
              = inline_svg("icon.svg")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # = link_to("", "/path")
        def test_sets_filename_on_offense
          source = <<~SLIM.chomp
            = link_to("", "/path")
          SLIM

          offenses = run_linter(
            source,
            filename: "app/views/index.html.slim"
          )

          assert_equal(
            "app/views/index.html.slim",
            offenses[0].filename
          )
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

          offenses = run_linter(source)

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

          offenses = run_linter(source)

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
            = link_to(\\
                "#",
                class: "icon",
              ) do
              = inline_svg("icon.svg")
              = t(".label")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def offense_message(method_name)
          "#{method_name} missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(source, filename: "test.slim")
          SlimRunner
            .new([LinkToMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
