# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestSkipNavigationLinkErb < Minitest::Test
        def test_layout_without_skip_link_reports_offense
          source = <<~ERB
            <div>
              <h1>Welcome</h1>
            </div>
          ERB

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.erb"
          )

          assert_equal(1, offenses.length)
          assert_equal("SkipNavigationLink", offenses[0].rule)
          assert_equal(1, offenses[0].line)
          assert_includes(offenses[0].message, "WCAG 2.4.1")
        end

        def test_layout_with_skip_link_passes
          source = <<~ERB
            <a href="#main-content">Skip to content</a>
            <div>
              <h1>Welcome</h1>
            </div>
          ERB

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.erb"
          )

          assert_empty(offenses)
        end

        def test_non_layout_file_without_skip_link_passes
          source = <<~ERB
            <div>
              <h1>Welcome</h1>
            </div>
          ERB

          offenses = run_linter(
            source,
            filename: "app/views/home/index.html.erb"
          )

          assert_empty(offenses)
        end

        def test_anchor_without_hash_href_does_not_count
          source = '<a href="/about">About</a>'

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.erb"
          )

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_hash_href_satisfies_rule
          source = '<a href="#content">Skip</a>'

          offenses = run_linter(
            source,
            filename: "app/views/layouts/application.html.erb"
          )

          assert_empty(offenses)
        end

        def test_nested_layouts_directory
          source = <<~ERB
            <div>
              <h1>Admin</h1>
            </div>
          ERB

          offenses = run_linter(
            source,
            filename: "app/views/layouts/admin/base.html.erb"
          )

          assert_equal(1, offenses.length)
        end

        def test_offense_sets_filename
          source = "<div></div>"
          filename = "app/views/layouts/application.html.erb"

          offenses = run_linter(source, filename:)

          assert_equal(filename, offenses[0].filename)
        end

        private

        def run_linter(source, filename:)
          ErbRunner.new(
            [], template_rules: [SkipNavigationLink.new]
          ).run(source, filename:)
        end
      end
    end
  end
end
