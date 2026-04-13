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

      def test_attribute_value_returns_string_value
        sexp = [
          :html, :tag, "a",
          [:html, :attrs,
           [:html, :attr, "href",
            [:escape, true, [:slim, :interpolate, "#main"]]]]
        ]
        node = Node.new(sexp, line: 1)

        assert_equal("#main", node.attribute_value("href"))
      end

      def test_attribute_value_returns_nil_when_absent
        sexp = [:html, :tag, "a", %i[html attrs]]
        node = Node.new(sexp, line: 1)

        assert_nil(node.attribute_value("href"))
      end

      def test_attribute_value_returns_nil_for_boolean_attribute
        sexp = [
          :html, :tag, "img",
          [:html, :attrs, [:html, :attr, "alt"]]
        ]
        node = Node.new(sexp, line: 1)

        assert_nil(node.attribute_value("alt"))
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

      def test_children_returns_direct_html_children
        sexp = Slim::Parser.new.call("ul\n  li one\n  li two\n")
        ul = sexp[1]
        node = Node.new(ul, line: 1)

        assert_equal(%w[li li], node.children.map(&:tag_name))
      end

      def test_children_walks_through_slim_control_blocks
        source = "ul\n  - items.each do |item|\n    li= item\n"
        sexp = Slim::Parser.new.call(source)
        ul = sexp[1]
        node = Node.new(ul, line: 1)

        assert_equal(["li"], node.children.map(&:tag_name))
      end

      def test_children_skips_slim_output_blocks
        source = "ul\n  = render \"items\"\n"
        sexp = Slim::Parser.new.call(source)
        ul = sexp[1]
        node = Node.new(ul, line: 1)

        assert_empty(node.children)
      end

      def test_children_returns_empty_for_non_html_nodes
        node = Node.new([:slim, :output, true, "code", [:multi]], line: 1)

        assert_empty(node.children)
      end
    end
  end
end
