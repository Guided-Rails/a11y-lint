# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestPhlexRunner < Minitest::Test
      def test_for_clean_source
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              img(src: "photo.jpg", alt: "A photo")
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_empty(offenses)
      end

      def test_img_without_alt
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              img(src: "photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal(1, offenses.length)
      end

      def test_rule_name
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              img(src: "photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal("ImgMissingAlt", offenses[0].rule)
      end

      def test_filename
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              img(src: "photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source, filename: "app/views/home_view.rb")

        assert_equal("app/views/home_view.rb", offenses[0].filename)
      end

      def test_line_number
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              div do
                img(src: "photo.jpg")
              end
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal(4, offenses[0].line)
      end

      def test_message
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              img(src: "photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal(
          "img tag is missing an alt attribute (WCAG 1.1.1)",
          offenses[0].message
        )
      end

      def test_line_numbers_across_multiple_elements
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              div do
                p { "Hello" }
                img(src: "a.jpg")
                span { "World" }
                img(src: "b.jpg")
              end
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal(2, offenses.length)
        assert_equal(5, offenses[0].line)
        assert_equal(7, offenses[1].line)
      end

      def test_image_tag_helper
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              image_tag("photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source, rules: [Rules::ImageTagMissingAlt])

        assert_equal(1, offenses.length)
      end

      def test_image_tag_helper_with_alt
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              image_tag("photo.jpg", alt: "A photo")
            end
          end
        RUBY

        offenses = run_linter(source, rules: [Rules::ImageTagMissingAlt])

        assert_empty(offenses)
      end

      def test_non_phlex_file_returns_empty
        source = "class User < ApplicationRecord; end"

        offenses = run_linter(source)

        assert_empty(offenses)
      end

      def test_ruby_file_without_view_template_is_skipped
        source = <<~RUBY
          class ImageHelper
            def img(src:)
              "<img src=\\"\#{src}\\">"
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_empty(offenses)
      end

      def test_application_component_subclass
        source = <<~RUBY
          class CardComponent < ApplicationComponent
            def view_template
              img(src: "photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal(1, offenses.length)
      end

      def test_application_view_subclass
        source = <<~RUBY
          class HomeView < ApplicationView
            def view_template
              img(src: "photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal(1, offenses.length)
      end

      def test_custom_base_class_subclass
        source = <<~RUBY
          class HomeView < Component::Base
            def view_template
              img(src: "photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source)

        assert_equal(1, offenses.length)
      end

      def test_mixed_tags_and_helpers
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              img(src: "a.jpg")
              image_tag("b.jpg")
            end
          end
        RUBY

        offenses = run_linter(
          source,
          rules: [Rules::ImgMissingAlt, Rules::ImageTagMissingAlt]
        )

        assert_equal(2, offenses.length)
        assert_equal("ImgMissingAlt", offenses[0].rule)
        assert_equal("ImageTagMissingAlt", offenses[1].rule)
      end

      def test_ignores_calls_with_receiver
        source = <<~RUBY
          class HomeView < Phlex::HTML
            def view_template
              helpers.image_tag("photo.jpg")
            end
          end
        RUBY

        offenses = run_linter(source, rules: [Rules::ImageTagMissingAlt])

        assert_empty(offenses)
      end

      private

      def run_linter(source, filename: "test_view.rb", rules: [Rules::ImgMissingAlt])
        PhlexRunner.new(rules).run(source, filename: filename)
      end
    end
  end
end
