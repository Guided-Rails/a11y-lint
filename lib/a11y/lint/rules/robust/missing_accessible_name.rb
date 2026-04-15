# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that link_to, external_link_to, and button_tag calls with
      # empty text or block content include an aria-label (WCAG 4.1.2).
      class MissingAccessibleName < Rule
        METHODS = %w[link_to external_link_to button_tag].freeze
        ICON_HELPERS = %w[inline_svg icon image_tag svg_icon].freeze

        def check
          call = @node.call_node
          return unless call && METHODS.include?(call.method_name)
          return if aria_label?(call)
          return unless call.first_positional_arg_empty_string? ||
                        (call.block? && icon_only_block?)

          offense_message(call.method_name)
        end

        private

        def aria_label?(call)
          call.has_keyword?(:aria, :label) ||
            call.has_keyword?(:"aria-label")
        end

        def offense_message(method_name)
          <<~MSG.strip
            #{method_name} missing an accessible name \
            requires an aria-label (WCAG 4.1.2)
          MSG
        end

        def icon_only_block?
          return false if @node.block_has_text_children?

          codes = @node.block_body_codes
          return true unless codes&.any?

          codes.all? { |code| icon_helper_call?(code) }
        end

        def icon_helper_call?(code)
          call = RubyCode.new(code).call_node
          call && ICON_HELPERS.include?(call.method_name)
        end
      end
    end
  end
end
