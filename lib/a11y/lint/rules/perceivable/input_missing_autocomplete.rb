# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that <input> elements include an autocomplete
      # attribute (WCAG 1.3.5).
      # https://www.w3.org/WAI/WCAG21/Understanding/identify-input-purpose.html
      class InputMissingAutocomplete < Rule
        EXCLUDED_TYPES = %w[
          hidden submit button reset image checkbox radio file
        ].freeze

        def check
          return unless an_input_missing_autocomplete?

          "input is missing an autocomplete attribute (WCAG 1.3.5)"
        end

        private

        def an_input_missing_autocomplete?
          node.tag_name == "input" &&
            !EXCLUDED_TYPES.include?(node.attributes["type"]) &&
            !node.attribute?("autocomplete")
        end
      end
    end
  end
end
