# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module A11y
  module Lint
    class TestErbNode < Minitest::Test
      def test_line
        node = ErbNode.new(nokogiri_node: make_element("img"), line: 5)

        result = node.line

        assert_equal(5, result)
      end

      def test_tag_name_for_html_element
        node = ErbNode.new(nokogiri_node: make_element("img"), line: 1)

        result = node.tag_name

        assert_equal("img", result)
      end

      def test_tag_name_returns_nil_for_ruby_code_node
        node = ErbNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 1)

        result = node.tag_name

        assert_nil(result)
      end

      def test_attribute_when_present
        element = make_element("img", "src" => "photo.jpg", "alt" => "A photo")
        node = ErbNode.new(nokogiri_node: element, line: 1)

        result = node.attribute?("alt")

        assert(result)
      end

      def test_attribute_when_absent
        element = make_element("img", "src" => "photo.jpg")
        node = ErbNode.new(nokogiri_node: element, line: 1)

        result = node.attribute?("alt")

        refute(result)
      end

      def test_attributes_with_multiple_attrs
        element = make_element("img", "src" => "photo.jpg", "alt" => "A photo")
        node = ErbNode.new(nokogiri_node: element, line: 1)

        result = node.attributes

        assert_equal({ "src" => "photo.jpg", "alt" => "A photo" }, result)
      end

      def test_attributes_returns_empty_hash_for_ruby_code_node
        node = ErbNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 1)

        result = node.attributes

        assert_equal({}, result)
      end

      def test_ruby_code_for_erb_output_node
        code = "image_tag \"photo.jpg\""
        node = ErbNode.new(ruby_code: code, line: 1)

        result = node.ruby_code

        assert_equal(code, result)
      end

      def test_ruby_code_returns_nil_for_html_element_node
        node = ErbNode.new(nokogiri_node: make_element("img"), line: 1)

        result = node.ruby_code

        assert_nil(result)
      end

      def test_children_returns_direct_element_children
        doc = Nokogiri::HTML4::DocumentFragment.parse(
          "<ul><li>one</li><li>two</li></ul>"
        )
        ul = doc.at_css("ul")
        node = ErbNode.new(nokogiri_node: ul, line: ul.line)

        result = node.children.map(&:tag_name)

        assert_equal(%w[li li], result)
      end

      def test_children_excludes_text_nodes
        doc = Nokogiri::HTML4::DocumentFragment.parse(
          "<ul>text<li>one</li></ul>"
        )
        ul = doc.at_css("ul")
        node = ErbNode.new(nokogiri_node: ul, line: ul.line)

        result = node.children.map(&:tag_name)

        assert_equal(["li"], result)
      end

      def test_children_returns_empty_for_ruby_code_node
        node = ErbNode.new(ruby_code: "render \"items\"", line: 1)

        result = node.children

        assert_empty(result)
      end

      def test_call_node_for_erb_output_node
        node = ErbNode.new(ruby_code: 'image_tag("photo.jpg")', line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("image_tag", result.method_name)
      end

      def test_call_node_returns_nil_for_html_element_node
        node = ErbNode.new(nokogiri_node: make_element("img"), line: 1)

        result = node.call_node

        assert_nil(result)
      end

      def test_call_node_with_block_form
        node = ErbNode.new(ruby_code: 'link_to("#") do', line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)

        assert(result.block?)
      end

      def test_call_node_with_multiline_code
        code = "link_to(\"#\",\n            class: \"icon\")"
        node = ErbNode.new(ruby_code: code, line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)
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
