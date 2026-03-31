# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestLinkMissingAccessibleNameErb < Minitest::Test
        def test_link_to_with_empty_text_reports_offense
          source = '<%= link_to("", "/path", class: "icon") %>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "link missing an accessible name requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("LinkMissingAccessibleName", offenses[0].rule)
        end

        def test_external_link_to_with_empty_text_reports_offense
          source = '<%= external_link_to("", "https://example.com", class: "icon") %>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_text_passes
          source = '<%= link_to("Click here", "/path") %>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_aria_hash_label_passes
          source = '<%= link_to("", "/path", aria: { label: "Facebook" }) %>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_string_aria_label_passes
          source = '<%= link_to("", "/path", "aria-label" => "Facebook") %>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_aria_hash_without_label_reports_offense
          source = '<%= link_to("", "/path", aria: { describedby: "desc" }) %>'

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
          source = '<%= link_to("", "/path") -%>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_non_output_erb_tags_ignored
          source = '<% link_to("", "/path") %>'

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
          assert_equal("link missing an accessible name requires an aria-label (WCAG 4.1.2)", offenses[0].message)
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
          filename = "app/views/index.html.erb"
          source = '<%= link_to("", "/path") %>'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.html.erb")
          ErbRunner.new([LinkMissingAccessibleName.new]).run(source, filename: filename)
        end
      end
    end
  end
end
