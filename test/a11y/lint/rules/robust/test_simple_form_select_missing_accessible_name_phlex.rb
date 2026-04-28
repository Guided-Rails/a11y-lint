# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    module Rules
      # The PhlexRunner only walks receiverless calls, so `form.input(...)`
      # is not surfaced as a candidate node. The rule is a no-op for Phlex
      # views by design (see issue #71 — Simple Form select detection is
      # narrowly scoped to template engines).
      class TestSimpleFormSelectMissingAccessibleNamePhlex < Minitest::Test
        def test_form_input_with_label_false_does_not_report
          source = <<~RUBY
            class TestView < Phlex::HTML
              def view_template
                simple_form_for(@model) do |form|
                  form.input(:sort_by, collection: opts, label: false)
                end
              end
            end
          RUBY

          offenses = run_linter(source)

          assert_empty(offenses)
        end

        private

        def run_linter(
          source, filename: "test_view.rb", configuration: Configuration.new
        )
          PhlexRunner
            .new([SimpleFormSelectMissingAccessibleName], configuration:)
            .run(source, filename:)
        end
      end
    end
  end
end
