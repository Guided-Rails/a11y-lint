# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestSimpleFormSelectMissingAccessibleNameErb < Minitest::Test
        def test_collection_with_label_false_reports_offense
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal(1, offenses[0].line)
          assert_equal(
            "SimpleFormSelectMissingAccessibleName", offenses[0].rule
          )
        end

        def test_collection_with_label_false_without_parens_reports_offense
          source = <<~ERB
            <%= form.input :sort_by, collection: opts, label: false %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_multiline_collection_with_label_false_reports_offense
          source = <<~ERB
            <%= form.input(
                  :sort_by,
                  collection: opts,
                  label: false,
                ) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_as_select_with_label_false_reports_offense
          source = <<~ERB
            <%= form.input(:sort_by, as: :select, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_label_empty_string_reports_offense
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: "") %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_aria_label_in_input_html_passes
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: false, input_html: { aria: { label: "Sort by" } }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_aria_label_in_input_html_without_parens_passes
          source = <<~ERB
            <%= form.input :sort_by, collection: opts, label: false, input_html: { aria: { label: "Sort by" } } %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_aria_label_in_input_html_passes
          source = <<~ERB
            <%= form.input(
                  :sort_by,
                  collection: opts,
                  label: false,
                  input_html: { aria: { label: "Sort by" } },
                ) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_string_aria_label_in_input_html_passes
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: false, input_html: { "aria-label" => "Sort by" }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_aria_labelledby_in_input_html_passes
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: false, input_html: { aria: { labelledby: "sort-label" } }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_string_aria_labelledby_in_input_html_passes
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: false, input_html: { "aria-labelledby" => "sort-label" }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_visible_label_passes
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: "Sort by") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_no_collection_or_as_select_passes
          source = <<~ERB
            <%= form.input(:name, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_as_string_select_does_not_match
          source = <<~ERB
            <%= form.input(:sort_by, as: :string, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_without_receiver_passes
          source = <<~ERB
            <%= input(:sort_by, collection: opts, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_f_builder_name_also_matches
          source = <<~ERB
            <%= f.input(:sort_by, collection: opts, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        private

        def offense_message
          "form.input select missing an accessible name " \
            "requires aria-label or aria-labelledby in input_html (WCAG 4.1.2)"
        end

        def run_linter(
          source, filename: "test.erb", configuration: Configuration.new
        )
          ErbRunner
            .new([SimpleFormSelectMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
