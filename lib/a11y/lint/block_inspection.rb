# frozen_string_literal: true

module A11y
  module Lint
    # Shared block-content queries for node types.
    # Depends on the host class implementing
    # #block_has_text_children? and #block_body_codes.
    module BlockInspection
      ICON_HELPERS = %w[inline_svg icon svg_icon].freeze

      def block_has_only_icon_helpers?
        return false if block_has_text_children?

        codes = block_body_codes
        return true unless codes&.any?

        codes.all? { |code| icon_helper_call?(code) }
      end

      private

      # image_tag is a conditional icon: it only counts as decorative
      # when it lacks a non-empty alt. A non-empty alt provides the
      # accessible name, matching how <a><img alt="Home"></a> is treated
      # by AnchorMissingAccessibleName#child_image_has_alt?.
      def icon_helper_call?(code)
        call = RubyCode.new(code).call_node
        return false unless call
        return true if ICON_HELPERS.include?(call.method_name)

        call.method_name == "image_tag" && !call.keyword_non_empty?(:alt)
      end
    end
  end
end
