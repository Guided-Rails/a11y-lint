# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that button_tag calls with empty text or block content
      # include an aria-label (WCAG 4.1.2).
      class ButtonTagMissingAccessibleName < NodeRule
        def check
          return if no_offense?

          offense_message
        end

        private

        def no_offense?
          !helper_call ||
            aria_label? ||
            !(helper_call.first_positional_arg_empty_string? ||
              (helper_call.block? && node.block_has_only_icon_helpers?))
        end

        def aria_label?
          helper_call.keyword?(:aria, :label) ||
            helper_call.keyword?(:"aria-label")
        end

        def helper_call
          @helper_call ||= begin
            call = node.call_node
            call if call && call.method_name == "button_tag"
          end
        end

        def offense_message
          <<~MSG.strip
            button_tag missing an accessible name \
            requires an aria-label (WCAG 4.1.2)
          MSG
        end
      end
    end
  end
end
