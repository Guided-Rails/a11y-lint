# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestInputMissingAutocompleteErb < Minitest::Test
        def test_input_without_autocomplete_reports_offense
          source = '<input type="text" name="username">'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "input is missing an autocomplete attribute (WCAG 1.3.5)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("InputMissingAutocomplete", offenses[0].rule)
        end

        def test_input_with_autocomplete_passes
          source = '<input type="text" name="username" autocomplete="username">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_with_autocomplete_on_passes
          source = '<input type="text" name="query" autocomplete="on">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_with_autocomplete_off_passes
          source = '<input type="text" name="otp" autocomplete="off">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_without_type_reports_offense
          source = '<input name="search">'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_input_hidden_without_autocomplete_passes
          source = '<input type="hidden" name="token">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_submit_without_autocomplete_passes
          source = '<input type="submit" value="Go">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_button_without_autocomplete_passes
          source = '<input type="button" value="Click">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_reset_without_autocomplete_passes
          source = '<input type="reset" value="Reset">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_image_without_autocomplete_passes
          source = '<input type="image" src="submit.png" alt="Submit">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_checkbox_without_autocomplete_passes
          source = '<input type="checkbox" name="agree">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_radio_without_autocomplete_passes
          source = '<input type="radio" name="color" value="red">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_file_without_autocomplete_passes
          source = '<input type="file" name="avatar">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_email_without_autocomplete_reports_offense
          source = '<input type="email" name="email">'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_input_tel_without_autocomplete_reports_offense
          source = '<input type="tel" name="phone">'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_nested_input_without_autocomplete
          source = <<~ERB
            <form>
              <input type="email" name="email">
            </form>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_inputs_reports_only_missing_autocomplete
          source = <<~ERB
            <input type="text" name="name" autocomplete="name">
            <input type="email" name="email">
            <input type="submit" value="Send">
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = '<input type="text" name="username">'

          offenses = run_linter(source, filename: "app/views/index.html.erb")

          assert_equal("app/views/index.html.erb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.html.erb")
          ErbRunner
            .new([InputMissingAutocomplete])
            .run(source, filename: filename)
        end
      end
    end
  end
end
