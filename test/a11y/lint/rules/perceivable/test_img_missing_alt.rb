# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestImgMissingAlt < Minitest::Test
        def test_img_without_alt_reports_offense
          source = 'img src="photo.jpg"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "img tag is missing an alt attribute (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("ImgMissingAlt", offenses[0].rule)
        end

        def test_img_with_alt_passes
          source = 'img src="photo.jpg" alt="A photo"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_img_with_empty_alt_passes
          source = 'img src="decorative.jpg" alt=""'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_img_without_alt
          source = "div\n  img src=\"photo.jpg\""

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_images_reports_only_missing
          source = <<~SLIM.chomp
            img src="a.jpg" alt="A"
            img src="b.jpg"
            img src="c.jpg" alt="C"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_deeply_nested_img
          source = "section\n  div\n    article\n      img src=\"deep.jpg\""
          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          filename = "app/views/index.html.slim"
          source = 'img src="photo.jpg"'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner.new([ImgMissingAlt]).run(source, filename: filename)
        end
      end
    end
  end
end
