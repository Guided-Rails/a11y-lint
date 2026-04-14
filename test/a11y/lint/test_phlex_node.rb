# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestPhlexNode < Minitest::Test
      def test_tag_name
        node = PhlexNode.new(tag_name: "img", line: 1)

        assert_equal("img", node.tag_name)
      end

      def test_tag_name_nil_for_helper
        node = PhlexNode.new(ruby_code: "link_to(\"Home\", root_path)", line: 1)

        assert_nil(node.tag_name)
      end

      def test_line
        node = PhlexNode.new(tag_name: "div", line: 5)

        assert_equal(5, node.line)
      end

      def test_attribute_present
        node = PhlexNode.new(
          tag_name: "img",
          attributes: { "src" => true, "alt" => true },
          line: 1
        )

        assert(node.attribute?("alt"))
      end

      def test_attribute_absent
        node = PhlexNode.new(
          tag_name: "img",
          attributes: { "src" => true },
          line: 1
        )

        refute(node.attribute?("alt"))
      end

      def test_attributes_returns_hash
        node = PhlexNode.new(
          tag_name: "img",
          attributes: { "src" => true, "alt" => true },
          line: 1
        )

        assert_equal({ "src" => true, "alt" => true }, node.attributes)
      end

      def test_attributes_empty_by_default
        node = PhlexNode.new(tag_name: "div", line: 1)

        assert_equal({}, node.attributes)
      end

      def test_ruby_code
        node = PhlexNode.new(
          ruby_code: "image_tag(\"photo.jpg\")",
          line: 1
        )

        assert_equal("image_tag(\"photo.jpg\")", node.ruby_code)
      end

      def test_ruby_code_nil_for_tag
        node = PhlexNode.new(tag_name: "img", line: 1)

        assert_nil(node.ruby_code)
      end

      def test_children
        child1 = PhlexNode.new(tag_name: "li", line: 2)
        child2 = PhlexNode.new(tag_name: "li", line: 3)
        parent = PhlexNode.new(
          tag_name: "ul",
          line: 1,
          children: [child1, child2]
        )

        assert_equal(2, parent.children.length)
        assert_equal("li", parent.children[0].tag_name)
        assert_equal("li", parent.children[1].tag_name)
      end

      def test_children_empty_by_default
        node = PhlexNode.new(tag_name: "img", line: 1)

        assert_empty(node.children)
      end
    end
  end
end
