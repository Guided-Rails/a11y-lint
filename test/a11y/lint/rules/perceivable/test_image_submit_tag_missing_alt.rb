# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestImageSubmitTagMissingAlt < Minitest::Test
        def test_image_submit_tag_without_alt_reports_offense
          source = '= image_submit_tag "submit.png"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "image_submit_tag is missing an alt option (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("ImageSubmitTagMissingAlt", offenses[0].rule)
        end

        def test_image_submit_tag_with_alt_symbol_key_passes
          source = '= image_submit_tag "submit.png", alt: "Submit"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_submit_tag_with_empty_alt_passes
          source = '= image_submit_tag "submit.png", alt: ""'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_submit_tag_with_parentheses_without_alt_reports_offense
          source = '= image_submit_tag("submit.png")'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_image_submit_tag_with_parentheses_and_alt_passes
          source = '= image_submit_tag("submit.png", alt: "Submit")'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_image_submit_tag_without_alt_reports_offense
          source = <<~SLIM.chomp
            = image_submit_tag(\\
                "submit.png",
                class: "btn",
              )
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_multiline_image_submit_tag_with_alt_passes
          source = <<~SLIM.chomp
            = image_submit_tag(\\
                "submit.png",
                alt: "Submit",
                class: "btn",
              )
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_submit_tag_with_other_options_but_no_alt_reports_offense
          source = '= image_submit_tag "submit.png", class: "btn"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_image_submit_tag_with_alt_among_other_options_passes
          source = <<~SLIM.chomp
            = image_submit_tag "submit.png", class: "btn", alt: "Submit"
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_submit_tag_with_hash_rocket_alt_passes
          source = '= image_submit_tag "submit.png", "alt" => "Submit"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_image_submit_tag_without_alt
          source = "div\n  = image_submit_tag \"submit.png\""

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_sets_filename_on_offense
          filename = "app/views/index.html.slim"
          source = '= image_submit_tag "submit.png"'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner
            .new([ImageSubmitTagMissingAlt])
            .run(source, filename: filename)
        end
      end
    end
  end
end
