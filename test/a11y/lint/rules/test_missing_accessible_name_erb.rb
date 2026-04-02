# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestMissingAccessibleNameErb < Minitest::Test
        # <%= link_to("", "/path", class: "icon") %>
        def test_link_to_with_empty_text_reports_offense
          offenses = run_fixture("link_to_empty_text")

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("link_to"),
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal(
            "MissingAccessibleName",
            offenses[0].rule
          )
        end

        # <%= external_link_to("", "https://example.com", class: "icon") %>
        def test_external_link_to_with_empty_text_reports_offense
          offenses = run_fixture("external_link_to_empty_text")

          assert_equal(1, offenses.length)
        end

        # <%= link_to("Click here", "/path") %>
        def test_link_to_with_text_passes
          offenses = run_fixture("link_to_with_text")

          assert_empty(offenses)
        end

        # <%= link_to("", "/path", aria: { label: "Facebook" }) %>
        def test_link_to_with_aria_hash_label_passes
          offenses = run_fixture("link_to_aria_hash_label")

          assert_empty(offenses)
        end

        # <%= link_to("", "/path", "aria-label" => "Facebook") %>
        def test_link_to_with_string_aria_label_passes
          offenses = run_fixture("link_to_string_aria_label")

          assert_empty(offenses)
        end

        # <%= link_to("", "/path", aria: { describedby: "desc" }) %>
        def test_link_to_with_aria_hash_without_label_reports_offense
          offenses = run_fixture("link_to_aria_hash_without_label")

          assert_equal(1, offenses.length)
        end

        # <div>
        #   <%= link_to("", "/path") %>
        # </div>
        def test_line_number_for_erb_output_tag
          offenses = run_fixture("link_to_nested")

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        # <div>
        # <%= link_to("",
        #             "/path",
        #             class: "icon") %>
        # </div>
        def test_multiline_erb_link_to
          offenses = run_fixture("link_to_multiline")

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        # <%= link_to("", "/path") -%>
        def test_trim_mode_erb_tag
          offenses = run_fixture("link_to_trim_mode")

          assert_equal(1, offenses.length)
        end

        # <% link_to("", "/path") %>
        def test_non_output_erb_tags_ignored
          offenses = run_fixture("link_to_non_output")

          assert_empty(offenses)
        end

        # <%= link_to("#", class: "icon") do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_link_to_with_block_reports_offense
          offenses = run_fixture("link_to_block")

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("link_to"),
            offenses[0].message
          )
        end

        # <%= link_to("#", class: "icon", aria: { label: "Icon" }) do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_link_to_with_block_and_aria_label_passes
          offenses = run_fixture("link_to_block_aria_label")

          assert_empty(offenses)
        end

        # <%= link_to "#", class: "icon" do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_link_to_with_block_without_parens_reports_offense
          offenses = run_fixture("link_to_block_no_parens")

          assert_equal(1, offenses.length)
        end

        # <%= link_to "#", class: "icon", aria: { label: "Icon" } do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_link_to_with_block_without_parens_and_aria_label_passes
          offenses = run_fixture("link_to_block_no_parens_aria_label")

          assert_empty(offenses)
        end

        # <%= link_to("#",
        #             class: "icon") do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_multiline_link_to_with_block_reports_offense
          offenses = run_fixture("link_to_multiline_block")

          assert_equal(1, offenses.length)
        end

        # <%= link_to("#",
        #             class: "icon",
        #             aria: { label: "Icon" }) do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_multiline_link_to_with_block_and_aria_label_passes
          offenses = run_fixture("link_to_multiline_block_aria_label")

          assert_empty(offenses)
        end

        # <%= external_link_to("https://example.com", class: "icon") do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_external_link_to_with_block_reports_offense
          offenses = run_fixture("external_link_to_block")

          assert_equal(1, offenses.length)
        end

        # <%= button_tag("", class: "icon") %>
        def test_button_tag_with_empty_text_reports_offense
          offenses = run_fixture("button_tag_empty_text")

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("button_tag"),
            offenses[0].message
          )
          assert_equal(
            "MissingAccessibleName",
            offenses[0].rule
          )
        end

        # <%= button_tag("Submit") %>
        def test_button_tag_with_text_passes
          offenses = run_fixture("button_tag_with_text")

          assert_empty(offenses)
        end

        # <%= button_tag("", class: "icon", aria: { label: "Submit" }) %>
        def test_button_tag_with_aria_hash_label_passes
          offenses = run_fixture("button_tag_aria_hash_label")

          assert_empty(offenses)
        end

        # <%= button_tag("", class: "icon", "aria-label" => "Submit") %>
        def test_button_tag_with_string_aria_label_passes
          offenses = run_fixture("button_tag_string_aria_label")

          assert_empty(offenses)
        end

        # <%= button_tag(class: "button-icon") do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_reports_offense
          offenses = run_fixture("button_tag_block")

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("button_tag"),
            offenses[0].message
          )
        end

        # <%= button_tag(class: "button-icon", aria: { label: "Menu" }) do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_and_aria_label_passes
          offenses = run_fixture("button_tag_block_aria_label")

          assert_empty(offenses)
        end

        # <%= button_tag class: "button-icon" do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_without_parens_reports_offense
          offenses = run_fixture("button_tag_block_no_parens")

          assert_equal(1, offenses.length)
        end

        # <%= button_tag class: "button-icon", aria: { label: "Menu" } do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_button_tag_with_block_without_parens_and_aria_label_passes
          offenses = run_fixture("button_tag_block_no_parens_aria_label")

          assert_empty(offenses)
        end

        # <%= button_tag(class: "button-icon",
        #                type: "button") do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_multiline_button_tag_with_block_reports_offense
          offenses = run_fixture("button_tag_multiline_block")

          assert_equal(1, offenses.length)
        end

        # <%= button_tag(class: "button-icon",
        #                aria: { label: "Menu" }) do %>
        #   <%= inline_svg("icon.svg") %>
        # <% end %>
        def test_multiline_button_tag_with_block_and_aria_label_passes
          offenses = run_fixture("button_tag_multiline_block_aria_label")

          assert_empty(offenses)
        end

        # <%= link_to("", "/path") %>
        def test_sets_filename_on_offense
          offenses = run_fixture(
            "link_to_sets_filename",
            filename: "app/views/index.html.erb"
          )

          assert_equal(
            "app/views/index.html.erb",
            offenses[0].filename
          )
        end

        private

        FIXTURE_DIR = File.expand_path(
          "../../../fixtures/missing_accessible_name/erb",
          __dir__
        )

        def offense_message(method_name)
          "#{method_name} missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_fixture(name, filename: "test.html.erb")
          source = File.read(
            File.join(FIXTURE_DIR, "#{name}.html.erb")
          )
          ErbRunner.new([MissingAccessibleName.new])
                   .run(source, filename: filename)
        end
      end
    end
  end
end
