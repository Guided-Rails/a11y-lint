# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleNameErb < Minitest::Test
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

        def test_button_tag_with_text_passes
          source = <<~ERB
            <%= button_tag("Submit") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_aria_hash_label_passes
          source = <<~ERB
            <%= button_tag("", class: "icon", aria: { label: "Submit" }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_string_aria_label_passes
          source = <<~ERB
            <%= button_tag("", class: "icon", "aria-label" => "Submit") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

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

        def test_button_tag_with_block_and_aria_label_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon", aria: { label: "Menu" }) do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_without_parens_reports_offense
          source = <<~ERB
            <%= button_tag class: "button-icon" do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_tag_with_block_without_parens_and_aria_label_passes
          source = <<~ERB
            <%= button_tag class: "button-icon", aria: { label: "Menu" } do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

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

        def test_button_tag_with_block_image_tag_non_empty_alt_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <%= image_tag("home.svg", alt: "Home") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_image_tag_alt_no_parens_passes
          source = <<~ERB
            <%= button_tag class: "button-icon" do %>
              <%= image_tag "home.svg", alt: "Home" %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_button_tag_with_block_image_tag_non_empty_alt_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon",
                           type: "button") do %>
              <%= image_tag("home.svg", alt: "Home") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_image_tag_dynamic_alt_passes
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <%= image_tag("home.svg", alt: @title) %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_block_image_tag_empty_alt_reports_offense
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <%= image_tag("home.svg", alt: "") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_button_tag_with_block_image_tag_no_alt_reports_offense
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <%= image_tag("home.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

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

        def test_hidden_wrapper_with_icon_passes_by_default
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <div class="popover"><%= t(".move") %></div>
              <%= inline_svg("thumbs-up.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_hidden_wrapper_with_icon_reports_when_configured
          source = <<~ERB
            <%= button_tag(class: "button-icon") do %>
              <div class="popover"><%= t(".move") %></div>
              <%= inline_svg("thumbs-up.svg") %>
            <% end %>
          ERB
          configuration = Configuration.new(
            "hidden_wrapper_classes" => ["popover"]
          )

          offenses = run_linter(source, configuration:)
          result = offenses.map(&:rule)

          assert_equal(["ButtonTagMissingAccessibleName"], result)
        end

        private

        def offense_message
          "button_tag missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(
          source, filename: "test.html.erb",
          configuration: Configuration.new
        )
          ErbRunner
            .new([ButtonTagMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
