# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestAnchorMissingAccessibleNamePhlex < Minitest::Test
        def test_empty_anchor_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "a tag is missing an accessible name " \
              "requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("AnchorMissingAccessibleName", offenses[0].rule)
        end

        def test_anchor_with_only_img_no_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { img(src: "icon.svg") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_only_img_empty_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { img(src: "icon.svg", alt: "") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_text_content_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { plain "Home" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_text_helper_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { text "Home" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_translation_helper_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { t(".dashboard") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_pluralize_helper_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { pluralize(count, "item") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_child_tag_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") do
                  span { plain "Home" }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path", aria_label: "Home")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_string_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path", "aria-label": "Home")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_nested_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path", aria: { label: "Home" })
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_nested_aria_label_dynamic_value_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path", aria: { label: t(".home_link") })
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_img_with_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") { img(src: "home.svg", alt: "Home") }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_anchor
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  a(href: "/path")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_anchors_reports_only_missing
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/home") { plain "Home" }
                a(href: "/profile")
                a(href: "/settings", aria_label: "Settings")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_deeply_nested_empty_anchor
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                section do
                  div do
                    nav do
                      a(href: "/path")
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
                a(href: "/path")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        def test_anchor_with_hidden_wrapper_text_passes_by_default
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") do
                  span(class: "popover") { plain "Move" }
                  img(src: "icon.svg")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_string_literal_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path", class: "text-sm") { "Clear all" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_interpolated_string_block_passes
          source = <<~'RUBY'
            class TestView < Phlex::HTML
              def view_template
                a(href: "/x") { "Hello, #{name}" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_method_call_with_receiver_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: admin_account_path(account), class: "link") do
                  account.email
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_index_access_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: tab[:href]) { tab[:text] }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_receiverless_lowercase_call_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: external_url, target: "_blank") { external_url }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_local_variable_param_block_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def link_for(text)
                a(href: "/path") { text }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_sr_only_text_among_components_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/back", class: "...") do
                  ArrowLongLeft(variant: :solid, aria_hidden: "true")
                  span(class: "sr-only") { "Back to " }
                  span { text }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_ternary_text_branch_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/x") { user ? user.email : "Guest" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_empty_string_literal_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/x") { "" }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_whitespace_string_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/x") { "   " }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_statement_then_nil_last_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/x") do
                  log_click
                  nil
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_only_capitalized_component_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/somewhere") do
                  Pencil(variant: :solid, class: "size-4")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_title_attribute_only_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/edit", title: "Edit profile") do
                  Pencil(variant: :solid)
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_aria_hidden_component_only_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/edit") do
                  Pencil(aria_hidden: "true")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_forwarding_block_argument_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def link(&block)
                a(href: "/x", class: "...", &block)
              end

              def view_template
                link do
                  span { text }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_forwarding_block_argument_with_mixed_children_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def link(&block)
                a(href: "/x", &block)
              end

              def view_template
                link do
                  span { text }
                  XMarkSolid(class: "size-4")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_string_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a("Click me", href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_interpolated_string_positional_arg_passes
          source = <<~'RUBY'
            class TestView < Phlex::HTML
              def view_template
                a("Hello, #{name}", href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_receiverless_lowercase_call_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(label_text, href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_method_call_with_receiver_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(user.name, href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_translation_helper_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(t(".label"), href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_local_variable_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def link_for(text)
                a(text, href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_empty_string_positional_arg_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a("", href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_whitespace_string_positional_arg_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a("   ", href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_capitalized_component_positional_arg_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(Pencil(variant: :solid), href: "/x")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_nested_anchor_with_string_positional_arg_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  a("Click me", href: "/x")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_hidden_wrapper_text_reports_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/path") do
                  span(class: "popover") { plain "Move" }
                  img(src: "icon.svg")
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "hidden_wrapper_classes" => ["popover"]
          )

          offenses = run_linter(source, configuration:)
          result = offenses.map(&:rule)

          assert_equal(["AnchorMissingAccessibleName"], result)
        end

        def test_anchor_with_sr_only_bare_html_tag_call_reports_by_default
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/back", class: "icon") do
                  span(class: "absolute -inset-2.5")
                  span(class: "sr-only") { label }
                  ChevronLeft(variant: :solid)
                end
              end
            end
          RUBY

          offenses = run_linter(source)
          result = offenses.map(&:rule)

          assert_equal(["AnchorMissingAccessibleName"], result)
        end

        def test_anchor_with_sr_only_bare_html_tag_call_passes_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/back", class: "icon") do
                  span(class: "absolute -inset-2.5")
                  span(class: "sr-only") { label }
                  ChevronLeft(variant: :solid)
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "accessible_name_wrapper_classes" => ["sr-only"]
          )

          offenses = run_linter(source, configuration:)

          assert_empty(offenses)
        end

        def test_anchor_with_sr_only_string_block_passes_when_configured
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/back", class: "icon") do
                  span(class: "sr-only") { "Back" }
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "accessible_name_wrapper_classes" => ["sr-only"]
          )

          offenses = run_linter(source, configuration:)

          assert_empty(offenses)
        end

        def test_anchor_with_sr_only_in_hidden_wrapper_classes_still_reports
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                a(href: "/back", class: "icon") do
                  span(class: "sr-only") { label }
                  ChevronLeft(variant: :solid)
                end
              end
            end
          RUBY
          configuration = Configuration.new(
            "hidden_wrapper_classes" => ["sr-only"]
          )

          offenses = run_linter(source, configuration:)
          result = offenses.map(&:rule)

          assert_equal(["AnchorMissingAccessibleName"], result)
        end

        private

        def run_linter(
          source, filename: "test_view.rb",
          configuration: Configuration.new
        )
          PhlexRunner
            .new([AnchorMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
