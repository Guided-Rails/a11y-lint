# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestBlockInspection < Minitest::Test
      def test_false_when_block_has_text_children
        node = build_node(block_has_text_children: true, codes: ['icon("x")'])

        result = node.block_has_only_icon_helpers?

        refute(result)
      end

      def test_true_when_no_block_body_codes
        node = build_node(block_has_text_children: false, codes: nil)

        result = node.block_has_only_icon_helpers?

        assert(result)
      end

      def test_true_when_block_body_codes_empty
        node = build_node(block_has_text_children: false, codes: [])

        result = node.block_has_only_icon_helpers?

        assert(result)
      end

      def test_true_for_inline_svg
        node = build_node(codes: ['inline_svg("logo.svg")'])

        result = node.block_has_only_icon_helpers?

        assert(result)
      end

      def test_true_for_icon
        node = build_node(codes: ['icon("arrow")'])

        result = node.block_has_only_icon_helpers?

        assert(result)
      end

      def test_true_for_image_tag
        node = build_node(codes: ['image_tag("photo.jpg")'])

        result = node.block_has_only_icon_helpers?

        assert(result)
      end

      def test_true_for_svg_icon
        node = build_node(codes: ['svg_icon("check")'])

        result = node.block_has_only_icon_helpers?

        assert(result)
      end

      def test_true_for_multiple_icon_helpers
        node = build_node(codes: ['icon("arrow")', 'inline_svg("logo.svg")'])

        result = node.block_has_only_icon_helpers?

        assert(result)
      end

      def test_false_when_code_is_not_icon_helper
        node = build_node(codes: ['render("partial")'])

        result = node.block_has_only_icon_helpers?

        refute(result)
      end

      def test_false_when_mixed_icon_and_non_icon
        node = build_node(codes: ['icon("arrow")', 'render("partial")'])

        result = node.block_has_only_icon_helpers?

        refute(result)
      end

      private

      def build_node(codes:, block_has_text_children: false)
        FakeNode.new(
          block_has_text_children: block_has_text_children,
          codes: codes
        )
      end

      class FakeNode
        include BlockInspection

        def initialize(block_has_text_children:, codes:)
          @block_has_text_children = block_has_text_children
          @codes = codes
        end

        def block_has_text_children?
          @block_has_text_children
        end

        def block_body_codes
          @codes
        end
      end
    end
  end
end
