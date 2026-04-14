# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestImageTagMissingAltPhlex < Minitest::Test
        def test_image_tag_without_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                image_tag("photo.jpg")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "image_tag is missing an alt option (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("ImageTagMissingAlt", offenses[0].rule)
        end

        def test_image_tag_with_alt_symbol_key_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                image_tag("photo.jpg", alt: "A photo")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_tag_with_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                image_tag("photo.jpg", alt: "")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_tag_with_other_options_but_no_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                image_tag("photo.jpg", class: "hero")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_image_tag_with_alt_among_other_options_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                image_tag("photo.jpg", class: "hero", alt: "A photo")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_tag_with_hash_rocket_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                image_tag("photo.jpg", "alt" => "A photo")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_image_tag_without_alt
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  image_tag("photo.jpg")
                end
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
                image_tag("photo.jpg")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner.new([ImageTagMissingAlt]).run(source, filename: filename)
        end
      end
    end
  end
end
