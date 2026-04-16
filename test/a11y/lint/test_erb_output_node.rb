# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestErbOutputNode < Minitest::Test
      def test_line
        node = ErbOutputNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 5)

        result = node.line

        assert_equal(5, result)
      end

      def test_tag_name_returns_nil
        node = ErbOutputNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 1)

        result = node.tag_name

        assert_nil(result)
      end

      def test_ruby_code
        code = "image_tag \"photo.jpg\""
        node = ErbOutputNode.new(ruby_code: code, line: 1)

        result = node.ruby_code

        assert_equal(code, result)
      end

      def test_attributes_returns_empty_hash
        node = ErbOutputNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 1)

        result = node.attributes

        assert_equal({}, result)
      end

      def test_attribute_returns_false
        node = ErbOutputNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 1)

        result = node.attribute?("alt")

        refute(result)
      end

      def test_children_returns_empty_array
        node = ErbOutputNode.new(ruby_code: "render \"items\"", line: 1)

        result = node.children

        assert_empty(result)
      end

      def test_call_node
        node = ErbOutputNode.new(ruby_code: 'image_tag("photo.jpg")', line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("image_tag", result.method_name)
      end

      def test_call_node_with_block_form
        node = ErbOutputNode.new(ruby_code: 'link_to("#") do', line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)
        assert(result.block?)
      end

      def test_call_node_with_multiline_code
        code = "link_to(\"#\",\n            class: \"icon\")"
        node = ErbOutputNode.new(ruby_code: code, line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)
      end
    end
  end
end
