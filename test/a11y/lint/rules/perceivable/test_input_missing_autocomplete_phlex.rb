# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      class TestInputMissingAutocompletePhlex < Minitest::Test
        def test_input_without_autocomplete_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "username")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(
            "input is missing an autocomplete attribute (WCAG 1.3.5)",
            offenses[0].message
          )
          assert_equal(3, offenses[0].line)
          assert_equal("InputMissingAutocomplete", offenses[0].rule)
        end

        def test_input_with_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "username", autocomplete: "username")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_with_autocomplete_on_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "query", autocomplete: "on")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_with_autocomplete_off_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "otp", autocomplete: "off")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_without_type_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(name: "search")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_input_hidden_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "hidden", name: "token")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_submit_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "submit", value: "Go")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_button_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "button", value: "Click")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_reset_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "reset", value: "Reset")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_image_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "image", src: "submit.png", alt: "Submit")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_checkbox_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "checkbox", name: "agree")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_radio_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "radio", name: "color", value: "red")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_file_without_autocomplete_passes
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "file", name: "avatar")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        def test_input_email_without_autocomplete_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "email", name: "email")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_input_tel_without_autocomplete_reports_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "tel", name: "phone")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
        end

        def test_nested_input_without_autocomplete
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                form do
                  input(type: "email", name: "email")
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_multiple_inputs_reports_only_missing_autocomplete
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "name", autocomplete: "name")
                input(type: "email", name: "email")
                input(type: "submit", value: "Send")
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_equal(1, offenses.length)
          assert_equal(4, offenses[0].line)
        end

        def test_sets_filename_on_offense
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                input(type: "text", name: "username")
              end
            end
          RUBY

          offenses = run_linter(source, filename: "app/views/index_view.rb")

          assert_equal("app/views/index_view.rb", offenses[0].filename)
        end

        private

        def run_linter(source, filename: "test_view.rb")
          PhlexRunner
            .new([InputMissingAutocomplete])
            .run(source, filename: filename)
        end
      end
    end
  end
end
