# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestAnchorMissingAccessibleNameSlim < Minitest::Test
        def test_empty_anchor_reports_offense
          source = 'a href="/path"'

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
          source = <<~SLIM.chomp
            a href="/path"
              img src="icon.svg"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_only_img_empty_alt_reports_offense
          source = <<~SLIM.chomp
            a href="/path"
              img src="icon.svg" alt=""
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_anchor_with_text_content_passes
          source = <<~SLIM.chomp
            a href="/path"
              | Home
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_dynamic_output_passes
          source = <<~SLIM.chomp
            a href="/path"
              = user.name
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_aria_label_passes
          source = 'a href="/path" aria-label="Home"'

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_img_with_alt_passes
          source = <<~SLIM.chomp
            a href="/path"
              img src="home.svg" alt="Home"
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_nested_empty_anchor
          source = <<~SLIM.chomp
            div
              a href="/path"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(2, offenses[0].line)
        end

        def test_multiple_anchors_reports_only_missing
          source = <<~SLIM.chomp
            a href="/home"
              | Home
            a href="/profile"
            a href="/settings" aria-label="Settings"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(3, offenses[0].line)
        end

        def test_deeply_nested_empty_anchor
          source = <<~SLIM.chomp
            section
              div
                nav
                  a href="/path"
          SLIM

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = 'a href="/path"'

          offenses = run_linter(
            source,
            filename: "app/views/index.html.slim"
          )

          assert_equal(
            "app/views/index.html.slim",
            offenses[0].filename
          )
        end

        def test_anchor_with_hidden_wrapper_text_passes_by_default
          source = <<~SLIM.chomp
            a href="/path"
              span.popover Move
              img src="icon.svg"
          SLIM

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_anchor_with_hidden_wrapper_text_reports_when_configured
          source = <<~SLIM.chomp
            a href="/path"
              span.popover Move
              img src="icon.svg"
          SLIM

          offenses = run_linter(
            source,
            configuration: Configuration.new(
              "hidden_wrapper_classes" => ["popover"]
            )
          )

          assert_equal(1, offenses.length)
          assert_equal("AnchorMissingAccessibleName", offenses[0].rule)
        end

        private

        def run_linter(
          source, filename: "test.slim", configuration: Configuration.new
        )
          SlimRunner
            .new([AnchorMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
