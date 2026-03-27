# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestNode < Minitest::Test
      def test_line
        line = 5

        node = Node.new([:html, :tag, "img", %i[html attrs]], line:)

        assert_equal(line, node.line)
      end

      def test_tag_name
        tag_name = "img"

        node = Node.new([:html, :tag, tag_name, %i[html attrs]], line: 1)

        assert_equal(tag_name, node.tag_name)
      end

      def test_attribute_when_present
        sexp = [:html, :tag, "img", [:html, :attrs, [:html, :attr, "alt"]]]
        node = Node.new(sexp, line: 1)

        result = node.attribute?("alt")

        assert(result)
      end

      def test_attribute_when_absent
        sexp = [:html, :tag, "img", %i[html attrs]]
        node = Node.new(sexp, line: 1)

        result = node.attribute?("alt")

        refute(result)
      end

      def test_attributes_with_multiple_attrs
        sexp = [
          :html, :tag, "img",
          [:html, :attrs, [:html, :attr, "src"], [:html, :attr, "alt"]]
        ]
        node = Node.new(sexp, line: 1)

        result = node.attributes

        assert_equal({ "src" => true, "alt" => true }, result)
      end

      def test_attributes_when_attrs_sexp_is_not_array
        sexp = [:html, :tag, "img", nil]
        node = Node.new(sexp, line: 1)

        result = node.attributes

        assert_equal({}, result)
      end

      def test_attributes__when_attrs_sexp_has_wrong_type
        sexp = [:html, :tag, "img", %i[slim attrs]]
        node = Node.new(sexp, line: 1)

        result = node.attributes

        assert_equal({}, result)
      end

      def test_ruby_code_for_slim_output_node
        code = "image_tag \"photo.jpg\""
        sexp = [:slim, :output, true, code, [:multi]]
        node = Node.new(sexp, line: 1)

        assert_equal(code, node.ruby_code)
      end

      def test_ruby_code_returns_nil_for_html_tag_node
        sexp = [:html, :tag, "img", %i[html attrs]]
        node = Node.new(sexp, line: 1)

        assert_nil(node.ruby_code)
      end
    end
  end
end
