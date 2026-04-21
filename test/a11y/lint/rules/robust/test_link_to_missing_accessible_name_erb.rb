# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestLinkToMissingAccessibleNameErb < Minitest::Test
        def test_link_to_with_empty_text_reports_offense
          source = <<~ERB
            <%= link_to("", "/path", class: "icon") %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("link_to"),
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal(
            "LinkToMissingAccessibleName",
            offenses[0].rule
          )
        end

        def test_external_link_to_with_empty_text_reports_offense
          source = <<~ERB
            <%= external_link_to("", "https://example.com", class: "icon") %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_text_passes
          source = <<~ERB
            <%= link_to("Click here", "/path") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_aria_hash_label_passes
          source = <<~ERB
            <%= link_to("", "/path", aria: { label: "Facebook" }) %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_string_aria_label_passes
          source = <<~ERB
            <%= link_to("", "/path", "aria-label" => "Facebook") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_aria_hash_without_label_reports_offense
          source = <<~ERB
            <%= link_to("", "/path", aria: { describedby: "desc" }) %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_line_number_for_erb_output_tag
          source = <<~ERB
            <div>
              <%= link_to("", "/path") %>
            </div>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiline_erb_link_to
          source = <<~ERB
            <div>
            <%= link_to("",
                        "/path",
                        class: "icon") %>
            </div>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_trim_mode_erb_tag
          source = <<~ERB
            <%= link_to("", "/path") -%>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_non_output_erb_tags_ignored
          source = <<~ERB
            <% link_to("", "/path") %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_reports_offense
          source = <<~ERB
            <%= link_to("#", class: "icon") do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("link_to"),
            offenses[0].message
          )
        end

        def test_link_to_with_block_and_aria_label_passes
          source = <<~ERB
            <%= link_to("#", class: "icon", aria: { label: "Icon" }) do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_without_parens_reports_offense
          source = <<~ERB
            <%= link_to "#", class: "icon" do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_block_without_parens_and_aria_label_passes
          source = <<~ERB
            <%= link_to "#", class: "icon", aria: { label: "Icon" } do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_link_to_with_block_reports_offense
          source = <<~ERB
            <%= link_to("#",
                        class: "icon") do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_multiline_link_to_with_block_and_aria_label_passes
          source = <<~ERB
            <%= link_to("#",
                        class: "icon",
                        aria: { label: "Icon" }) do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_external_link_to_with_block_reports_offense
          source = <<~ERB
            <%= external_link_to("https://example.com", class: "icon") do %>
              <%= inline_svg("icon.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_sets_filename_on_offense
          source = <<~ERB
            <%= link_to("", "/path") %>
          ERB

          offenses = run_linter(
            source,
            filename: "app/views/index.html.erb"
          )

          assert_equal(
            "app/views/index.html.erb",
            offenses[0].filename
          )
        end

        def test_link_to_with_block_image_tag_non_empty_alt_passes
          source = <<~ERB
            <%= link_to("/home") do %>
              <%= image_tag("home.svg", alt: "Home") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_image_tag_alt_no_parens_passes
          source = <<~ERB
            <%= link_to "/home" do %>
              <%= image_tag "home.svg", alt: "Home" %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_link_to_with_block_image_tag_non_empty_alt_passes
          source = <<~ERB
            <%= link_to("/home",
                        class: "icon") do %>
              <%= image_tag("home.svg", alt: "Home") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_image_tag_dynamic_alt_passes
          source = <<~ERB
            <%= link_to("/home") do %>
              <%= image_tag("home.svg", alt: @title) %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_image_tag_empty_alt_reports_offense
          source = <<~ERB
            <%= link_to("/home") do %>
              <%= image_tag("home.svg", alt: "") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_block_image_tag_no_alt_reports_offense
          source = <<~ERB
            <%= link_to("/home") do %>
              <%= image_tag("home.svg") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_block_and_text_passes
          source = <<~ERB
            <%= link_to("#", class: "icon") do %>
              <%= inline_svg("icon.svg") %>
              <%= t(".label") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_without_parens_and_text_passes
          source = <<~ERB
            <%= link_to "#", class: "icon" do %>
              <%= inline_svg("icon.svg") %>
              <%= t(".label") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_link_to_with_block_and_text_passes
          source = <<~ERB
            <%= link_to("#",
                        class: "icon") do %>
              <%= inline_svg("icon.svg") %>
              <%= t(".label") %>
            <% end %>
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def offense_message(method_name)
          "#{method_name} missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(source, filename: "test.html.erb")
          ErbRunner
            .new([LinkToMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
