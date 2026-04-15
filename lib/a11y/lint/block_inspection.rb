# frozen_string_literal: true

module A11y
  module Lint
    # Shared block-content queries for node types.
    # Depends on the host class implementing
    # #block_has_text_children? and #block_body_codes.
    module BlockInspection
      ICON_HELPERS = %w[inline_svg icon image_tag svg_icon].freeze

      def block_has_only_icon_helpers?
        return false if block_has_text_children?

        codes = block_body_codes
        return true unless codes&.any?

        codes.all? { |code| icon_helper_call?(code) }
      end

      private

      def icon_helper_call?(code)
        call = RubyCode.new(code).call_node
        call && ICON_HELPERS.include?(call.method_name)
      end
    end
  end
end
