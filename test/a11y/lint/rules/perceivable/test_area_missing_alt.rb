# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestAreaMissingAlt < Minitest::Test
        def test_area_without_alt_reports_offense
          source = 'area shape="rect" coords="0,0,82,126" href="/sun"'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "area tag is missing an alt attribute (WCAG 1.1.1)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("AreaMissingAlt", offenses[0].rule)
        end

        def test_area_with_alt_passes
          source = 'area shape="rect" coords="0,0,82,126" href="/sun" alt="Sun"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_area_with_empty_alt_passes
          source = 'area shape="rect" coords="0,0,82,126" href="/sun" alt=""'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_area_without_alt
          source = "map\n  area shape=\"rect\" href=\"/sun\""

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_areas_reports_only_missing
          source = <<~SLIM.chomp
            area shape="rect" href="/sun" alt="Sun"
            area shape="circle" href="/moon"
            area shape="poly" href="/star" alt="Star"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_deeply_nested_area
          source = <<~SLIM.chomp
            section
              div
                map
                  area shape="rect" href="/sun"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          filename = "app/views/index.html.slim"
          source = 'area shape="rect" href="/sun"'

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.slim")
          SlimRunner.new([AreaMissingAlt]).run(source, filename: filename)
        end
      end
    end
  end
end
