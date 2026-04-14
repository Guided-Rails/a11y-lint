# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestImgMissingAltPhlex < Minitest::Test
        def test_img_without_alt_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                img(src: "photo.jpg")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "img tag is missing an alt attribute (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("ImgMissingAlt", offenses[0].rule)
        end

        def test_img_with_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                img(src: "photo.jpg", alt: "A photo")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_img_with_empty_alt_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                img(src: "decorative.jpg", alt: "")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_img_without_alt
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                div do
                  img(src: "photo.jpg")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_images_reports_only_missing
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                img(src: "a.jpg", alt: "A")
                img(src: "b.jpg")
                img(src: "c.jpg", alt: "C")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_deeply_nested_img
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                section do
                  div do
                    article do
                      img(src: "deep.jpg")
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
                img(src: "photo.jpg")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner.new([ImgMissingAlt]).run(source, filename: filename)
        end
      end
    end
  end
end
