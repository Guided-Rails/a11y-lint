# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestLinkToMissingAccessibleNamePhlex < Minitest::Test
        def test_link_to_with_empty_text_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("", "/path", class: "icon")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message("link_to"), offenses[0].message)
          assert_equal(3, offenses[0].line)
          assert_equal("LinkToMissingAccessibleName", offenses[0].rule)
        end

        def test_external_link_to_with_empty_text_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                external_link_to("", "https://example.com", class: "icon")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            offense_message("external_link_to"),
            offenses[0].message
          )
        end

        def test_link_to_with_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("Click here", "/path")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_aria_hash_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("", "/path", aria: { label: "Facebook" })
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_string_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("", "/path", "aria-label" => "Facebook")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_aria_hash_without_label_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("", "/path", aria: { describedby: "desc" })
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("#", class: "icon") do
                  span(class: "icon-home")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message("link_to"), offenses[0].message)
          assert_equal(3, offenses[0].line)
        end

        def test_link_to_with_block_and_aria_label_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("#", class: "icon", aria: { label: "Icon" }) do
                  span(class: "icon-home")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_brace_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("#", class: "icon") {
                  span(class: "icon-home")
                }
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(offense_message("link_to"), offenses[0].message)
        end

        def test_external_link_to_with_block_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                external_link_to("https://example.com", class: "icon") do
                  span(class: "icon-external")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_block_image_tag_non_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("/home") do
                  image_tag("home.svg", alt: "Home")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_image_tag_alt_no_parens_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to "/home" do
                  image_tag "home.svg", alt: "Home"
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_multiline_link_to_with_block_image_tag_non_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to(
                  "/home",
                  class: "icon",
                ) do
                  image_tag("home.svg", alt: "Home")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_image_tag_dynamic_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("/home") do
                  image_tag("home.svg", alt: @title)
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_image_tag_empty_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("/home") do
                  image_tag("home.svg", alt: "")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_block_image_tag_no_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("/home") do
                  image_tag("home.svg")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_link_to_with_block_and_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("#", class: "icon") do
                  inline_svg("icon.svg")
                  span { t(".label") }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_external_link_to_with_block_and_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                external_link_to("https://example.com", class: "icon") do
                  inline_svg("icon.svg")
                  span { t(".label") }
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_and_plain_text_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("#", class: "icon") do
                  inline_svg("icon.svg")
                  plain t(".label")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_link_to_with_block_and_yield_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to(href, class: classes, **aria_attrs) do
                  span { label }
                  yield
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_non_matching_method_is_ignored
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                submit_tag("", "/path")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_sets_filename_on_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                link_to("", "/path")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def offense_message(method_name)
          "#{method_name} missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner.new([LinkToMissingAccessibleName]).run(source, filename:)
        end
      end
    end
  end
end
