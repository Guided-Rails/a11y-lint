# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that Simple Form `form.input` calls rendering a select
      # (via `collection:` or `as: :select`) with `label: false` /
      # `label: ""` provide an accessible name through `input_html:`
      # `aria-label` or `aria-labelledby` (WCAG 4.1.2).
      class SimpleFormSelectMissingAccessibleName < NodeRule
        def check
          return if no_offense?

          offense_message
        end

        private

        def no_offense?
          !helper_call ||
            !select_like? ||
            !helper_call.label_hidden? ||
            aria_label_in_input_html?
        end

        def select_like?
          helper_call.keyword?(:collection) ||
            helper_call.keyword_symbol?(:as, :select)
        end

        def aria_label_in_input_html?
          helper_call.keyword?(:input_html, :aria, :label) ||
            helper_call.keyword?(:input_html, :"aria-label") ||
            helper_call.keyword?(:input_html, :aria, :labelledby) ||
            helper_call.keyword?(:input_html, :"aria-labelledby")
        end

        def helper_call
          return @helper_call if defined?(@helper_call)

          @helper_call = find_input_call
        end

        def find_input_call
          return nil unless node.respond_to?(:ruby_code) && node.ruby_code

          call = RubyCode.new(node.ruby_code).top_level_call_node
          return nil unless call && call.method_name == "input"
          return nil if call.prism_node.receiver.nil?

          call
        end

        def offense_message
          <<~MSG.strip
            form.input select missing an accessible name \
            requires aria-label or aria-labelledby in input_html (WCAG 4.1.2)
          MSG
        end
      end
    end
  end
end
