# frozen_string_literal: true

require "test_helper"
require "slim"

module A11y
  module Lint
    class TestSlimNode < Minitest::Test
      def test_line
        line = 5
        node = SlimNode.new([:html, :tag, "img", %i[html attrs]], line:)

        result = node.line

        assert_equal(line, result)
      end

      def test_tag_name
        tag_name = "img"
        node = SlimNode.new([:html, :tag, tag_name, %i[html attrs]], line: 1)

        result = node.tag_name

        assert_equal(tag_name, result)
      end

      def test_attribute_when_present
        sexp = [:html, :tag, "img", [:html, :attrs, [:html, :attr, "alt"]]]
        node = SlimNode.new(sexp, line: 1)

        result = node.attribute?("alt")

        assert(result)
      end

      def test_attribute_when_absent
        sexp = [:html, :tag, "img", %i[html attrs]]
        node = SlimNode.new(sexp, line: 1)

        result = node.attribute?("alt")

        refute(result)
      end

      def test_attributes_with_multiple_attrs
        sexp = [
          :html, :tag, "img",
          [:html, :attrs, [:html, :attr, "src"], [:html, :attr, "alt"]]
        ]
        node = SlimNode.new(sexp, line: 1)

        result = node.attributes

        assert_equal({ "src" => true, "alt" => true }, result)
      end

      def test_attributes_when_attrs_sexp_is_not_array
        sexp = [:html, :tag, "img", nil]
        node = SlimNode.new(sexp, line: 1)

        result = node.attributes

        assert_equal({}, result)
      end

      def test_attributes__when_attrs_sexp_has_wrong_type
        sexp = [:html, :tag, "img", %i[slim attrs]]
        node = SlimNode.new(sexp, line: 1)

        result = node.attributes

        assert_equal({}, result)
      end

      def test_ruby_code_for_slim_output_node
        code = "image_tag \"photo.jpg\""
        sexp = [:slim, :output, true, code, [:multi]]
        node = SlimNode.new(sexp, line: 1)

        result = node.ruby_code

        assert_equal(code, result)
      end

      def test_ruby_code_returns_nil_for_html_tag_node
        sexp = [:html, :tag, "img", %i[html attrs]]
        node = SlimNode.new(sexp, line: 1)

        result = node.ruby_code

        assert_nil(result)
      end

      def test_children_returns_direct_html_children
        sexp = Slim::Parser.new.call("ul\n  li one\n  li two\n")
        ul = sexp[1]
        node = SlimNode.new(ul, line: 1)

        result = node.children.map(&:tag_name)

        assert_equal(%w[li li], result)
      end

      def test_children_walks_through_slim_control_blocks
        source = "ul\n  - items.each do |item|\n    li= item\n"
        sexp = Slim::Parser.new.call(source)
        ul = sexp[1]
        node = SlimNode.new(ul, line: 1)

        result = node.children.map(&:tag_name)

        assert_equal(["li"], result)
      end

      def test_children_skips_slim_output_blocks
        source = "ul\n  = render \"items\"\n"
        sexp = Slim::Parser.new.call(source)
        ul = sexp[1]
        node = SlimNode.new(ul, line: 1)

        result = node.children

        assert_empty(result)
      end

      def test_children_returns_empty_for_non_html_nodes
        node = SlimNode.new([:slim, :output, true, "code", [:multi]], line: 1)

        result = node.children

        assert_empty(result)
      end

      def test_call_node_for_slim_output_node
        sexp = [:slim, :output, true, 'image_tag("photo.jpg")', [:multi]]
        node = SlimNode.new(sexp, line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("image_tag", result.method_name)
      end

      def test_call_node_returns_nil_for_html_tag_node
        sexp = [:html, :tag, "img", %i[html attrs]]
        node = SlimNode.new(sexp, line: 1)

        result = node.call_node

        assert_nil(result)
      end

      def test_call_node_with_block_form
        sexp = [:slim, :output, true, 'link_to("#") do', [:multi]]
        node = SlimNode.new(sexp, line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)

        assert(result.block?)
      end

      def test_call_node_with_multiline_code
        code = "link_to(\n    \"\",\n    \"/path\",\n    class: \"icon\",\n  )"
        sexp = [:slim, :output, true, code, [:multi]]
        node = SlimNode.new(sexp, line: 1)

        result = node.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)
      end
    end
  end
end
