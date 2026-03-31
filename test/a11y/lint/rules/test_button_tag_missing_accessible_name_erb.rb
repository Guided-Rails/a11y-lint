# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestButtonTagMissingAccessibleNameErb < Minitest::Test
        def test_button_tag_with_empty_text_reports_offense
          source = '<%= button_tag("", class: "icon") %>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "button_tag missing an accessible name requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("ButtonTagMissingAccessibleName", offenses[0].rule)
        end

        def test_button_tag_with_text_passes
          source = '<%= button_tag("Submit") %>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_aria_hash_label_passes
          source = '<%= button_tag("", class: "icon", aria: { label: "Submit" }) %>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_string_aria_label_passes
          source = '<%= button_tag("", class: "icon", "aria-label" => "Submit") %>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_button_tag_with_aria_hash_without_label_reports_offense
          source = '<%= button_tag("", class: "icon", aria: { describedby: "desc" }) %>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_line_number_for_erb_output_tag
          source = <<~ERB
            <div>
              <%= button_tag("", class: "icon") %>
            </div>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiline_erb_button_tag
          source = <<~ERB
            <div>
            <%= button_tag("",
                           class: "icon") %>
            </div>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_trim_mode_erb_tag
          source = '<%= button_tag("", class: "icon") -%>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_non_output_erb_tags_ignored
          source = '<% button_tag("", class: "icon") %>'

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
          assert_equal("button_tag missing an accessible name requires an aria-label (WCAG 4.1.2)", offenses[0].message)
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

        def test_sets_filename_on_offense
          filename = "app/views/index.html.erb"
          source = '<%= button_tag("", class: "icon") %>'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.html.erb")
          ErbRunner.new([ButtonTagMissingAccessibleName.new]).run(source, filename: filename)
        end
      end
    end
  end
end
