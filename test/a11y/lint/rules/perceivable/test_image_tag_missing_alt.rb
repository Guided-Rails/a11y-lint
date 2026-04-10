# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestImageTagMissingAlt < Minitest::Test
        def test_image_tag_without_alt_reports_offense
          source = '= image_tag "photo.jpg"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "image_tag is missing an alt option (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("ImageTagMissingAlt", offenses[0].rule)
        end

        def test_image_tag_with_alt_symbol_key_passes
          source = '= image_tag "photo.jpg", alt: "A photo"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_tag_with_empty_alt_passes
          source = '= image_tag "photo.jpg", alt: ""'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_tag_with_parentheses_without_alt_reports_offense
          source = '= image_tag("photo.jpg")'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_image_tag_with_parentheses_and_alt_passes
          source = '= image_tag("photo.jpg", alt: "A photo")'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_tag_with_other_options_but_no_alt_reports_offense
          source = '= image_tag "photo.jpg", class: "hero"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_image_tag_with_alt_among_other_options_passes
          source = '= image_tag "photo.jpg", class: "hero", alt: "A photo"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_image_tag_with_hash_rocket_alt_passes
          source = '= image_tag "photo.jpg", "alt" => "A photo"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_image_tag_without_alt
          source = "div\n  = image_tag \"photo.jpg\""

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_image_tag_nested_in_link_to_without_alt_reports_offense
          source = '= link_to(image_tag("logo.svg"), root_path)'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_image_tag_nested_in_link_to_with_alt_passes
          source = '= link_to(image_tag("logo.svg", alt: "Logo"), root_path)'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_alt_in_filename_still_reports_offense
          source = '= image_tag "icons/alt:native.png"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_sets_filename_on_offense
          filename = "app/views/index.html.slim"
          source = '= image_tag "photo.jpg"'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner
            .new([ImageTagMissingAlt])
            .run(source, filename: filename)
        end
      end
    end
  end
end
