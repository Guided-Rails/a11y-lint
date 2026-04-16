# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonMissingAccessibleNameSlim < Minitest::Test
        def test_empty_button_reports_offense
          source = 'button type="submit"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "button tag is missing an accessible name " \
              "requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("ButtonMissingAccessibleName", offenses[0].rule)
        end

        def test_button_with_only_img_no_alt_reports_offense
          source = <<~SLIM.chomp
            button type="button"
              img src="icon.svg"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_only_img_empty_alt_reports_offense
          source = <<~SLIM.chomp
            button type="button"
              img src="icon.svg" alt=""
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_text_content_passes
          source = <<~SLIM.chomp
            button type="submit"
              | Submit
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_dynamic_output_passes
          source = <<~SLIM.chomp
            button type="submit"
              = t(".submit")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_aria_label_passes
          source = 'button type="button" aria-label="Close"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_img_with_alt_passes
          source = <<~SLIM.chomp
            button type="button"
              img src="close.svg" alt="Close"
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_button
          source = <<~SLIM.chomp
            div
              button type="button"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_buttons_reports_only_missing
          source = <<~SLIM.chomp
            button type="submit"
              | Submit
            button type="button"
            button type="button" aria-label="Close"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(3, offenses[0].line)
        end

        def test_deeply_nested_empty_button
          source = <<~SLIM.chomp
            section
              div
                form
                  button type="submit"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = 'button type="button"'

          offenses = run_linter(
            source,
            filename: "app/views/index.html.slim"
          )

          assert_equal(
            "app/views/index.html.slim",
            offenses[0].filename
          )
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner
            .new([ButtonMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
