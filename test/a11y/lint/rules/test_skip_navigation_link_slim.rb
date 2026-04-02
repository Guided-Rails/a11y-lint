# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestSkipNavigationLinkSlim < Minitest::Test
        def test_layout_without_skip_link_reports_offense
          source = <<~SLIM.chomp
            div
              h1 Welcome
          SLIM

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.slim"
          )

          assert_equal(1, offenses.length)
          assert_equal("SkipNavigationLink", offenses[0].rule)
          assert_equal(1, offenses[0].line)
          assert_includes(offenses[0].message, "WCAG 2.4.1")
        end

        def test_layout_with_skip_link_passes
          source = <<~SLIM.chomp
            a href="#main-content" Skip to content
            div
              h1 Welcome
          SLIM

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.slim"
          )

          assert_empty(offenses)
        end

        def test_non_layout_file_without_skip_link_passes
          source = <<~SLIM.chomp
            div
              h1 Welcome
          SLIM

          offenses = run_linter(
            source,
            filename: "app/views/home/index.html.slim"
          )

          assert_empty(offenses)
        end

        def test_anchor_without_hash_href_does_not_count
          source = 'a href="/about" About'

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.slim"
          )

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_hash_href_satisfies_rule
          source = 'a href="#content" Skip'

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.slim"
          )

          assert_empty(offenses)
        end

        def test_nested_layouts_directory
          source = <<~SLIM.chomp
            div
              h1 Admin
          SLIM

          offenses = run_linter(
            source,
            filename: "app/views/layouts/admin/base.html.slim"
          )

          assert_equal(1, offenses.length)
        end

        def test_offense_sets_filename
          source = "div"
          filename = "app/views/layouts/application.html.slim"

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename:)
          SlimRunner.new(
            [], template_rules: [SkipNavigationLink.new]
          ).run(source, filename:)
        end
      end
    end
  end
end
