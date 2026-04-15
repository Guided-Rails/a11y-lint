# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestAreaMissingAltErb < Minitest::Test
        def test_area_without_alt_reports_offense
          source = '<area shape="rect" coords="0,0,82,126" href="/sun">'

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
          source = <<~ERB.chomp
            <area shape="rect" coords="0,0,82,126" href="/sun" alt="Sun">
          ERB

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_area_with_empty_alt_passes
          source = '<area shape="rect" coords="0,0,82,126" href="/sun" alt="">'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_area_without_alt
          source = <<~ERB
            <map name="infographic">
              <area shape="rect" href="/sun">
            </map>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_areas_reports_only_missing
          source = <<~ERB
            <area shape="rect" href="/sun" alt="Sun">
            <area shape="circle" href="/moon">
            <area shape="poly" href="/star" alt="Star">
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_deeply_nested_area
          source = <<~ERB
            <section>
              <div>
                <map name="nav">
                  <area shape="rect" href="/sun">
                </map>
              </div>
            </section>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = '<area shape="rect" href="/sun">'

          offenses = run_linter(source, filename: "app/views/index.html.erb")

          assert_equal("app/views/index.html.erb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test.html.erb")
          ErbRunner.new([AreaMissingAlt]).run(source, filename: filename)
        end
      end
    end
  end
end
