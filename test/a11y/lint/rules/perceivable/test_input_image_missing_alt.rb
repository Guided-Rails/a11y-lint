# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestInputImageMissingAlt < Minitest::Test
        def test_input_image_without_alt_reports_offense
          source = 'input type="image" src="submit.png"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "input type=\"image\" is missing an alt attribute (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("InputImageMissingAlt", offenses[0].rule)
        end

        def test_input_image_with_alt_passes
          source = 'input type="image" src="submit.png" alt="Submit"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_image_with_empty_alt_passes
          source = 'input type="image" src="submit.png" alt=""'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_text_without_alt_passes
          source = 'input type="text" name="username"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_submit_without_alt_passes
          source = 'input type="submit" value="Go"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_input_image_without_alt
          source = <<~SLIM.chomp
            form
              input type="image" src="submit.png"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_inputs_reports_only_image_missing_alt
          source = <<~SLIM.chomp
            input type="text" name="q"
            input type="image" src="go.png"
            input type="image" src="search.png" alt="Search"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_sets_filename_on_offense
          filename = "app/views/index.html.slim"
          source = 'input type="image" src="submit.png"'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner.new([InputImageMissingAlt]).run(source, filename: filename)
        end
      end
    end
  end
end
