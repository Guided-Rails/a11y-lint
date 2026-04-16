# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleNameErb < Minitest::Test
        # <%= button_tag("", class: "icon") %>
        def test_button_tag_with_empty_text_reports_offense
          source = <<~ERB
            <%= button_tag("", class: "icon") %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
          assert_equal(
            "ButtonTagMissingAccessibleName",
            offenses[0].rule
          )
        end

        # <%= button_tag("Submit") %>
        def test_button_tag_with_text_passes
          source = <<~ERB
            <%= button_tag("Submit") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag("", class: "icon", aria: { label: "Submit" }) %>
        def test_button_tag_with_aria_hash_label_passes
          source = <<~ERB
            <%= button_tag("", class: "icon", aria: { label: "Submit" }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag("", class: "icon", "aria-label" => "Submit") %>
        def test_button_tag_with_string_aria_label_passes
          source = <<~ERB
            <%= button_tag("", class: "icon", "aria-label" => "Submit") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag(class: "button-icon") do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_reports_offense
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message, offenses[0].message)
        end

        # <%= button_tag(class: "button-icon", aria: { label: "Menu" }) do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_and_aria_label_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon", aria: { label: "Menu" }) do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag class: "button-icon" do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_without_parens_reports_offense
          source = <<~ERB
            <%= button_tag class: "button-icon" do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # <%= button_tag class: "button-icon", aria: { label: "Menu" } do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_without_parens_and_aria_label_passes
          source = <<~ERB
            <%= button_tag class: "button-icon", aria: { label: "Menu" } do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag(class: "button-icon",
        #                type: "button") do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_multiline_button_tag_with_block_reports_offense
          source = <<~ERB
            <%= button_tag(class: "button-icon",
                           type: "button") do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        # <%= button_tag(class: "button-icon",
        #                aria: { label: "Menu" }) do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_multiline_button_tag_with_block_and_aria_label_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon",
                           aria: { label: "Menu" }) do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag(class: "button-icon") do %>
        #   <%= inline_svg("icon.svg") %>
        #   <%= t(".label") %>
        # <% end %>
        def test_button_tag_with_block_and_text_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <%= inline_svg("icon.svg") %>
              <%= t(".label") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag class: "button-icon" do %>
        #   <%= inline_svg("icon.svg") %>
        #   <%= t(".label") %>
        # <% end %>
        def test_button_tag_with_block_without_parens_and_text_passes
          source = <<~ERB
            <%= button_tag class: "button-icon" do %>
              <%= inline_svg("icon.svg") %>
              <%= t(".label") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        # <%= button_tag(class: "button-icon",
        #                type: "button") do %>
        #   <%= inline_svg("icon.svg") %>
        #   <%= t(".label") %>
        # <% end %>
        def test_multiline_button_tag_with_block_and_text_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon",
                           type: "button") do %>
              <%= inline_svg("icon.svg") %>
              <%= t(".label") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def offense_message
          "button_tag missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(source, filename: "test.html.erb")
          ErbRunner
            .new([ButtonTagMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
