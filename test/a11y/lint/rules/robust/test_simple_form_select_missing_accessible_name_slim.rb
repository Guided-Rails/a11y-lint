# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestSimpleFormSelectMissingAccessibleNameSlim < Minitest::Test
        def test_collection_with_label_false_reports_offense
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: false)
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal(1, offenses[0].line)
          assert_equal(
            "SimpleFormSelectMissingAccessibleName", offenses[0].rule
          )
        end

        def test_collection_with_label_false_without_parens_reports_offense
          source = <<~SLIM.chomp
            = form.input :sort_by, collection: opts, label: false
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_multiline_collection_with_label_false_reports_offense
          source = <<~SLIM.chomp
            = form.input(\\
                :sort_by,
                collection: opts,
                label: false,
              )
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_as_select_with_label_false_reports_offense
          source = <<~SLIM.chomp
            = form.input(:sort_by, as: :select, label: false)
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_label_empty_string_reports_offense
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: "")
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_aria_label_in_input_html_passes
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: false, input_html: { aria: { label: "Sort by" } })
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_aria_label_in_input_html_without_parens_passes
          source = <<~SLIM.chomp
            = form.input :sort_by, collection: opts, label: false, input_html: { aria: { label: "Sort by" } }
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_aria_label_in_input_html_passes
          source = <<~SLIM.chomp
            = form.input(\\
                :sort_by,
                collection: opts,
                label: false,
                input_html: { aria: { label: "Sort by" } },
              )
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_string_aria_label_in_input_html_passes
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: false, input_html: { "aria-label" => "Sort by" })
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_aria_labelledby_in_input_html_passes
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: false, input_html: { aria: { labelledby: "sort-label" } })
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_string_aria_labelledby_in_input_html_passes
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: false, input_html: { "aria-labelledby" => "sort-label" })
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_visible_label_passes
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: "Sort by")
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_no_collection_or_as_select_passes
          source = <<~SLIM.chomp
            = form.input(:name, label: false)
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_as_string_select_does_not_match
          source = <<~SLIM.chomp
            = form.input(:sort_by, as: :string, label: false)
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_without_receiver_passes
          source = <<~SLIM.chomp
            = input(:sort_by, collection: opts, label: false)
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_other_form_helper_is_ignored
          source = <<~SLIM.chomp
            = form.select(:sort_by, opts, label: false)
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_f_builder_name_also_matches
          source = <<~SLIM.chomp
            = f.input(:sort_by, collection: opts, label: false)
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_sets_filename_on_offense
          source = <<~SLIM.chomp
            = form.input(:sort_by, collection: opts, label: false)
          SLIM

          offenses = run_linter(
            source, filename: "app/views/index.html.slim"
          )

          assert_equal(
            "app/views/index.html.slim", offenses[0].filename
          )
        end

        private

        def offense_message
          "form.input select missing an accessible name " \
            "requires aria-label or aria-labelledby in input_html (WCAG 4.1.2)"
        end

        def run_linter(
          source, filename: "test.slim", configuration: Configuration.new
        )
          SlimRunner
            .new([SimpleFormSelectMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
