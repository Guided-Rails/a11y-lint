# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module A11y
  module Lint
    class TestErbElementNode < Minitest::Test
      def test_line
        node = ErbElementNode.new(nokogiri_node: make_element("img"), line: 5)

        result = node.line

        assert_equal(5, result)
      end

      def test_tag_name
        node = ErbElementNode.new(nokogiri_node: make_element("img"), line: 1)

        result = node.tag_name

        assert_equal("img", result)
      end

      def test_attribute_when_present
        element = make_element("img", "src" => "photo.jpg", "alt" => "A photo")
        node = ErbElementNode.new(nokogiri_node: element, line: 1)

        result = node.attribute?("alt")

        assert(result)
      end

      def test_attribute_when_absent
        element = make_element("img", "src" => "photo.jpg")
        node = ErbElementNode.new(nokogiri_node: element, line: 1)

        result = node.attribute?("alt")

        refute(result)
      end

      def test_attributes_with_multiple_attrs
        element = make_element("img", "src" => "photo.jpg", "alt" => "A photo")
        node = ErbElementNode.new(nokogiri_node: element, line: 1)

        result = node.attributes

        assert_equal({ "src" => "photo.jpg", "alt" => "A photo" }, result)
      end

      def test_call_node_returns_nil
        node = ErbElementNode.new(nokogiri_node: make_element("img"), line: 1)

        result = node.call_node

        assert_nil(result)
      end

      def test_ruby_code_returns_nil
        node = ErbElementNode.new(nokogiri_node: make_element("img"), line: 1)

        result = node.ruby_code

        assert_nil(result)
      end

      def test_children_returns_direct_element_children
        doc = Nokogiri::HTML4::DocumentFragment.parse(
          "<ul><li>one</li><li>two</li></ul>"
        )
        ul = doc.at_css("ul")
        node = ErbElementNode.new(nokogiri_node: ul, line: ul.line)

        result = node.children.map(&:tag_name)

        assert_equal(%w[li li], result)
      end

      def test_children_excludes_text_nodes
        doc = Nokogiri::HTML4::DocumentFragment.parse(
          "<ul>text<li>one</li></ul>"
        )
        ul = doc.at_css("ul")
        node = ErbElementNode.new(nokogiri_node: ul, line: ul.line)

        result = node.children.map(&:tag_name)

        assert_equal(["li"], result)
      end

      def test_children_are_erb_element_nodes
        doc = Nokogiri::HTML4::DocumentFragment.parse(
          "<ul><li>one</li></ul>"
        )
        ul = doc.at_css("ul")
        node = ErbElementNode.new(nokogiri_node: ul, line: ul.line)

        result = node.children.first

        assert_instance_of(ErbElementNode, result)
      end

      private

      def make_element(tag, attrs = {})
        doc = Nokogiri::HTML4::Document.new
        element = Nokogiri::XML::Node.new(tag, doc)
        attrs.each { |name, value| element[name] = value }
        element
      end
    end
  end
end
