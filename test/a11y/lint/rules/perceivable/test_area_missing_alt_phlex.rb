# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestAreaMissingAltPhlex < Minitest::Test
        def test_area_without_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                area(shape: "rect", href: "/sun")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "area tag is missing an alt attribute (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("AreaMissingAlt", offenses[0].rule)
        end

        def test_area_with_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                area(shape: "rect", href: "/sun", alt: "Sun")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_area_with_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                area(shape: "rect", href: "/sun", alt: "")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_area_without_alt
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  area(shape: "rect", href: "/sun")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_areas_reports_only_missing
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                area(shape: "rect", href: "/sun", alt: "Sun")
                area(shape: "circle", href: "/moon")
                area(shape: "poly", href: "/star", alt: "Star")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_deeply_nested_area
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                section do
                  div do
                    map do
                      area(shape: "rect", href: "/sun")
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
                area(shape: "rect", href: "/sun")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner.new([AreaMissingAlt]).run(source, filename: filename)
        end
      end
    end
  end
end
