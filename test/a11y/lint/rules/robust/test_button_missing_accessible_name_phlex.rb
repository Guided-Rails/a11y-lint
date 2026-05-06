# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonMissingAccessibleNamePhlex < Minitest::Test
        def test_empty_button_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "button tag is missing an accessible name " \
              "requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("ButtonMissingAccessibleName", offenses[0].rule)
        end

        def test_button_with_only_img_no_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") { img(src: "icon.svg") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_only_img_empty_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") { img(src: "icon.svg", alt: "") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_text_content_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { plain "Submit" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_text_helper_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { text "Submit" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_translation_helper_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { t(".submit") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_number_helper_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { number_to_currency(price) }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_child_tag_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") do
                  span { plain "Submit" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button", aria_label: "Close")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_string_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button", "aria-label": "Close")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_nested_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button", aria: { label: "Close" })
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_nested_aria_label_dynamic_value_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button", aria: { label: t(".close") })
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_img_with_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") { img(src: "close.svg", alt: "Close") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_button
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  button(type: "button")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_buttons_reports_only_missing
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { plain "Submit" }
                button(type: "button")
                button(type: "button", aria_label: "Close")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_deeply_nested_empty_button
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                section do
                  div do
                    form do
                      button(type: "submit")
                    end
                  end
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(6, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        def test_button_with_inaccessible_wrapper_text_passes_by_default
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") do
                  span(class: "popover") { plain "Move" }
                  img(src: "thumbs-up.svg")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_string_literal_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: :submit, class: "btn") { "Filter" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_interpolated_string_block_passes
          source = <<~'RUBY'
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { "Save #{record.name}" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_method_call_with_receiver_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { record.action_label }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_receiverless_lowercase_call_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button", class: "btn btn-secondary") do
                  add_label
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_local_variable_param_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def submit(label)
                button(type: "submit") { label }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_sr_only_label_among_components_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def menu_button(label)
                button(class: "...", data: { testid: "dropdown-trigger" }) do
                  span(class: "absolute -inset-2.5")
                  span(class: "sr-only") { label }
                  EllipsisVertical(variant: :solid, aria_hidden: "true")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_ternary_text_branch_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { saving? ? "Saving..." : "Save" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_empty_string_literal_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { "" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_whitespace_string_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "submit") { "   " }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_statement_then_nil_last_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") do
                  log_click
                  nil
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_only_capitalized_component_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") do
                  EllipsisVertical(variant: :solid)
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_aria_hidden_component_only_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") do
                  EllipsisVertical(aria_hidden: "true")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_forwarding_block_argument_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def submit(&block)
                button(type: "submit", class: "btn", &block)
              end

              def view_template
                submit do
                  span { text }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_forwarding_block_argument_with_mixed_children_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def submit(&block)
                button(type: "submit", &block)
              end

              def view_template
                submit do
                  span { text }
                  XMarkSolid(class: "size-4")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_string_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button("Submit", type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_interpolated_string_positional_arg_passes
          source = <<~'RUBY'
            class TestView < Phlex::HTML
              def view_template
                button("Save #{name}", type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_receiverless_lowercase_call_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(label_text, type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_method_call_with_receiver_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(form.label, type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_translation_helper_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(t(".submit"), type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_local_variable_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def submit_for(text)
                button(text, type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_empty_string_positional_arg_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button("", type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_whitespace_string_positional_arg_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button("   ", type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_with_capitalized_component_positional_arg_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(Pencil(variant: :solid), type: :submit)
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_nested_button_with_string_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  button("Submit", type: :submit)
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_with_inaccessible_wrapper_text_reports_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(type: "button") do
                  span(class: "popover") { plain "Move" }
                  img(src: "thumbs-up.svg")
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "inaccessible_wrapper_classes" => ["popover"]
          )

          offenses = run_linter(source, configuration:)
          result = offenses.map(&:rule)

          assert_equal(["ButtonMissingAccessibleName"], result)
        end

        def test_button_with_sr_only_bare_html_tag_call_reports_by_default
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(class: "icon") do
                  span(class: "absolute -inset-2.5")
                  span(class: "sr-only") { label }
                  EllipsisVertical(variant: :solid)
                end
              end
            end
          RUBY

          offenses = run_linter(source)
          result = offenses.map(&:rule)

          assert_equal(["ButtonMissingAccessibleName"], result)
        end

        def test_button_with_sr_only_bare_html_tag_call_passes_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(class: "icon") do
                  span(class: "absolute -inset-2.5")
                  span(class: "sr-only") { label }
                  EllipsisVertical(variant: :solid)
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "accessible_wrapper_classes" => ["sr-only"]
          )

          offenses = run_linter(source, configuration:)

          assert_empty(offenses)
        end

        def test_button_with_sr_only_string_block_passes_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(class: "icon") do
                  span(class: "sr-only") { "Open menu" }
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "accessible_wrapper_classes" => ["sr-only"]
          )

          offenses = run_linter(source, configuration:)

          assert_empty(offenses)
        end

        def test_sr_only_in_inaccessible_wrapper_classes_still_reports
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                button(class: "icon") do
                  span(class: "sr-only") { label }
                  EllipsisVertical(variant: :solid)
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "inaccessible_wrapper_classes" => ["sr-only"]
          )

          offenses = run_linter(source, configuration:)
          result = offenses.map(&:rule)

          assert_equal(["ButtonMissingAccessibleName"], result)
        end

        private

        def run_linter(
          source, filename: "test_view.rb",
          configuration: Configuration.new
        )
          PhlexRunner
            .new([ButtonMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
