# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that link_to and external_link_to calls with empty text or
      # block content include an aria-label (WCAG 4.1.2).
      class LinkToMissingAccessibleName < NodeRule
        METHODS = %w[link_to external_link_to].freeze

        def check
          return if no_offense?

          offense_message(helper_call.method_name)
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
            call if call && METHODS.include?(call.method_name)
          end
        end

        def offense_message(method_name)
          <<~MSG.strip
            #{method_name} missing an accessible name \
            requires an aria-label (WCAG 4.1.2)
          MSG
        end
      end
    end
  end
end
