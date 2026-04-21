# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonMissingAccessibleNameErb < Minitest::Test
        def test_empty_button_reports_offense
          source = '<button type="submit"></button>'

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
          source = '<button type="button"><img src="icon.svg"></button>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_only_img_empty_alt_reports_offense
          source = '<button type="button"><img src="icon.svg" alt=""></button>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_text_content_passes
          source = '<button type="submit">Submit</button>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_erb_output_passes
          source = '<button type="submit"><%= t(".submit") %></button>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_aria_label_passes
          source = '<button type="button" aria-label="Close"></button>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_img_with_alt_passes
          source = <<~ERB.chomp
            <button type="button"><img src="close.svg" alt="Close"></button>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_button
          source = <<~ERB
            <div>
              <button type="button"></button>
            </div>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_buttons_reports_only_missing
          source = <<~ERB
            <button type="submit">Submit</button>
            <button type="button"></button>
            <button type="button" aria-label="Close"></button>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_deeply_nested_empty_button
          source = <<~ERB
            <section>
              <div>
                <form>
                  <button type="submit"></button>
                </form>
              </div>
            </section>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = '<button type="button"></button>'

          offenses = run_linter(
            source,
            filename: "app/views/index.html.erb"
          )

          assert_equal(
            "app/views/index.html.erb",
            offenses[0].filename
          )
        end

        def test_button_with_hidden_wrapper_text_passes_by_default
          source = <<~ERB
            <button type="button">
              <span class="popover">Move</span>
              <img src="thumbs-up.svg">
            </button>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_hidden_wrapper_text_reports_when_configured
          source = <<~ERB
            <button type="button">
              <span class="popover">Move</span>
              <img src="thumbs-up.svg">
            </button>
          ERB

          offenses = run_linter(
            source,
            configuration: Configuration.new(
              "hidden_wrapper_classes" => ["popover"]
            )
          )

          assert_equal(1, offenses.length)
          assert_equal("ButtonMissingAccessibleName", offenses[0].rule)
        end

        private

        def run_linter(
          source, filename: "test.html.erb",
          configuration: Configuration.new
        )
          ErbRunner
            .new([ButtonMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
