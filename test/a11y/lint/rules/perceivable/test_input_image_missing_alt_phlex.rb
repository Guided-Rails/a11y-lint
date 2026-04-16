# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestInputImageMissingAltPhlex < Minitest::Test
        def test_input_image_without_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "image", src: "submit.png")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "input type=\"image\" is missing an alt attribute (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("InputImageMissingAlt", offenses[0].rule)
        end

        def test_input_image_with_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "image", src: "submit.png", alt: "Submit")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_image_with_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "image", src: "submit.png", alt: "")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_text_without_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "username")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_submit_without_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "submit", value: "Go")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_input_image_without_alt
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                form do
                  input(type: "image", src: "submit.png")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_inputs_reports_only_image_missing_alt
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "q")
                input(type: "image", src: "go.png")
                input(type: "image", src: "search.png", alt: "Search")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "image", src: "submit.png")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner
            .new([InputImageMissingAlt])
            .run(source, filename: filename)
        end
      end
    end
  end
end
