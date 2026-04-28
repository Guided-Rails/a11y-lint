# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestSimpleFormInputMissingAccessibleNameErb < Minitest::Test
        def test_text_input_with_label_false_reports_offense
          source = <<~ERB
            <%= form.input(:name, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal(1, offenses[0].line)
          assert_equal(
            "SimpleFormInputMissingAccessibleName", offenses[0].rule
          )
        end

        def test_text_input_with_label_false_without_parens_reports_offense
          source = <<~ERB
            <%= form.input :name, label: false %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_multiline_text_input_with_label_false_reports_offense
          source = <<~ERB
            <%= form.input(
                  :name,
                  label: false,
                ) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_text_input_with_aria_label_passes
          source = <<~ERB
            <%= form.input(:name, label: false, input_html: { aria: { label: "Name" } }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_text_input_with_string_aria_label_passes
          source = <<~ERB
            <%= form.input(:name, label: false, input_html: { "aria-label" => "Name" }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_collection_with_label_false_reports_offense
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: false) %>
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

        def test_as_string_with_label_false_reports_offense
          source = <<~ERB
            <%= form.input(:name, as: :string, label: false) %>
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

        def test_collection_with_aria_label_in_input_html_passes
          source = <<~ERB
            <%= form.input(:sort_by, collection: opts, label: false, input_html: { aria: { label: "Sort by" } }) %>
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

        def test_default_label_passes
          source = <<~ERB
            <%= form.input(:name) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_as_hidden_with_label_false_passes
          source = <<~ERB
            <%= form.input(:secret, as: :hidden, label: false) %>
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

        def test_other_form_helper_is_ignored
          source = <<~ERB
            <%= form.select(:sort_by, opts, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_f_builder_name_also_matches
          source = <<~ERB
            <%= f.input(:name, label: false) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        private

        def offense_message
          "form.input missing an accessible name " \
            "requires aria-label or aria-labelledby in input_html (WCAG 4.1.2)"
        end

        def run_linter(
          source, filename: "test.erb", configuration: Configuration.new
        )
          ErbRunner
            .new([SimpleFormInputMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
