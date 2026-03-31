# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleName < Minitest::Test
        def test_button_tag_with_empty_text_reports_offense
          source = '= button_tag("", class: "icon")'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "button_tag missing an accessible name requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("ButtonTagMissingAccessibleName", offenses[0].rule)
        end

        def test_button_tag_with_empty_text_without_parens_reports_offense
          source = '= button_tag "", class: "icon"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_multiline_button_tag_with_trailing_comma_reports_offense
          source = "= button_tag(\\\n    \"\",\n    class: \"icon\",\n  )"

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_tag_with_text_passes
          source = '= button_tag("Submit")'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_aria_hash_label_passes
          source = '= button_tag("", class: "icon", aria: { label: "Submit" })'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_without_parens_and_aria_label_passes
          source = '= button_tag "", class: "icon", aria: { label: "Submit" }'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_button_tag_with_trailing_comma_and_aria_label_passes
          source = "= button_tag(\\\n    \"\",\n    class: \"icon\",\n    aria: { label: \"Submit\" },\n  )"

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_string_aria_label_passes
          source = '= button_tag("", class: "icon", "aria-label" => "Submit")'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_aria_hash_without_label_reports_offense
          source = '= button_tag("", class: "icon", aria: { describedby: "desc" })'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_tag_with_block_reports_offense
          source = "= button_tag(class: \"button-icon\") do\n  = inline_svg(\"icon.svg\")"

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "button_tag missing an accessible name requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("ButtonTagMissingAccessibleName", offenses[0].rule)
        end

        def test_button_tag_with_block_and_aria_label_passes
          source = "= button_tag(class: \"button-icon\", aria: { label: \"Menu\" }) do\n  = inline_svg(\"icon.svg\")"

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_without_parens_reports_offense
          source = "= button_tag class: \"button-icon\" do\n  = inline_svg(\"icon.svg\")"

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_tag_with_block_without_parens_and_aria_label_passes
          source = "= button_tag class: \"button-icon\", aria: { label: \"Menu\" } do\n  = inline_svg(\"icon.svg\")"

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_button_tag_with_block_reports_offense
          source = "= button_tag(\\\n    class: \"button-icon\",\n  ) do\n  = inline_svg(\"icon.svg\")"

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_multiline_button_tag_with_block_and_aria_label_passes
          source = "= button_tag(\\\n    class: \"button-icon\",\n" \
                   "    aria: { label: \"Menu\" },\n  ) do\n  = inline_svg(\"icon.svg\")"

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_button_tag_with_empty_text
          source = "div\n  = button_tag(\"\", class: \"icon\")"

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_non_button_tag_method_is_ignored
          source = '= submit_tag("", class: "icon")'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_sets_filename_on_offense
          filename = "app/views/index.html.slim"
          source = '= button_tag("", class: "icon")'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner.new([ButtonTagMissingAccessibleName.new]).run(source, filename: filename)
        end
      end
    end
  end
end
