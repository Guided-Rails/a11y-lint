# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module A11y
  module Lint
    class TestErbNode < Minitest::Test
      def test_line
        node = ErbNode.new(nokogiri_node: make_element("img"), line: 5)

        assert_equal(5, node.line)
      end

      def test_tag_name_for_html_element
        node = ErbNode.new(nokogiri_node: make_element("img"), line: 1)

        assert_equal("img", node.tag_name)
      end

      def test_tag_name_returns_nil_for_ruby_code_node
        node = ErbNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 1)

        assert_nil(node.tag_name)
      end

      def test_attribute_when_present
        element = make_element("img", "src" => "photo.jpg", "alt" => "A photo")
        node = ErbNode.new(nokogiri_node: element, line: 1)

        assert(node.attribute?("alt"))
      end

      def test_attribute_when_absent
        element = make_element("img", "src" => "photo.jpg")
        node = ErbNode.new(nokogiri_node: element, line: 1)

        refute(node.attribute?("alt"))
      end

      def test_attributes_with_multiple_attrs
        element = make_element("img", "src" => "photo.jpg", "alt" => "A photo")
        node = ErbNode.new(nokogiri_node: element, line: 1)

        assert_equal({ "src" => true, "alt" => true }, node.attributes)
      end

      def test_attributes_returns_empty_hash_for_ruby_code_node
        node = ErbNode.new(ruby_code: "image_tag \"photo.jpg\"", line: 1)

        assert_equal({}, node.attributes)
      end

      def test_ruby_code_for_erb_output_node
        code = "image_tag \"photo.jpg\""
        node = ErbNode.new(ruby_code: code, line: 1)

        assert_equal(code, node.ruby_code)
      end

      def test_ruby_code_returns_nil_for_html_element_node
        node = ErbNode.new(nokogiri_node: make_element("img"), line: 1)

        assert_nil(node.ruby_code)
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
