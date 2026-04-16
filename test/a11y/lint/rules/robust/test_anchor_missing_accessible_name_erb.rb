# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestAnchorMissingAccessibleNameErb < Minitest::Test
        def test_empty_anchor_reports_offense
          source = '<a href="/path"></a>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "a tag is missing an accessible name " \
              "requires an aria-label (WCAG 4.1.2)",
            offenses[0].message
          )
          assert_equal(1, offenses[0].line)
          assert_equal("AnchorMissingAccessibleName", offenses[0].rule)
        end

        def test_anchor_with_only_img_no_alt_reports_offense
          source = '<a href="/path"><img src="icon.svg"></a>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_only_img_empty_alt_reports_offense
          source = '<a href="/path"><img src="icon.svg" alt=""></a>'

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_text_content_passes
          source = '<a href="/path">Home</a>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_erb_output_passes
          source = '<a href="/path"><%= user.name %></a>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_aria_label_passes
          source = '<a href="/path" aria-label="Home"></a>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_img_with_alt_passes
          source = '<a href="/path"><img src="home.svg" alt="Home"></a>'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_anchor
          source = <<~ERB
            <div>
              <a href="/path"></a>
            </div>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_anchors_reports_only_missing
          source = <<~ERB
            <a href="/home">Home</a>
            <a href="/profile"></a>
            <a href="/settings" aria-label="Settings"></a>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_deeply_nested_empty_anchor
          source = <<~ERB
            <section>
              <div>
                <nav>
                  <a href="/path"></a>
                </nav>
              </div>
            </section>
          ERB

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = '<a href="/path"></a>'

          offenses = run_linter(
            source,
            filename: "app/views/index.html.erb"
          )

          assert_equal(
            "app/views/index.html.erb",
            offenses[0].filename
          )
        end

        private

        def run_linter(source, filename: "test.html.erb")
          ErbRunner
            .new([AnchorMissingAccessibleName])
            .run(source, filename:)
        end
      end
    end
  end
end
