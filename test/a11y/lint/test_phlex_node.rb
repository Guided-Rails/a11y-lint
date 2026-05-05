# frozen_string_literal: true

require "test_helper"
require "prism"

module A11y
  module Lint
    class TestPhlexNode < Minitest::Test
      def test_tag_name
        node = PhlexNode.new(tag_name: "img", line: 1)

        assert_equal("img", node.tag_name)
      end

      def test_tag_name_nil_for_helper
        parsed = Prism.parse("link_to(\"Home\", root_path)")
        call_node = parsed.value.statements.body.first
        node = PhlexNode.new(call_node: call_node, line: 1)

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

      def test_call_node
        parsed = Prism.parse("image_tag(\"photo.jpg\")")
        call_node = parsed.value.statements.body.first
        node = PhlexNode.new(call_node: call_node, line: 1)

        assert_equal("image_tag", node.call_node.name.to_s)
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

      def test_build_tag_extracts_string_attribute_values
        call_node = parse_call('img(src: "photo.jpg", alt: "A photo")')
        node = PhlexNode.build_tag(call_node)

        assert_equal(
          { "src" => "photo.jpg", "alt" => "A photo" },
          node.attributes
        )
      end

      def test_build_tag_extracts_symbol_attribute_values
        call_node = parse_call("input(type: :submit)")
        node = PhlexNode.build_tag(call_node)

        assert_equal({ "type" => "submit" }, node.attributes)
      end

      def test_build_tag_falls_back_to_true_for_non_literal_values
        call_node = parse_call("img(src: src_path, alt: alt_text)")
        node = PhlexNode.build_tag(call_node)

        assert_equal({ "src" => true, "alt" => true }, node.attributes)
      end

      def test_build_tag_with_no_arguments
        call_node = parse_call("div")
        node = PhlexNode.build_tag(call_node)

        assert_equal({}, node.attributes)
      end

      def test_build_tag_flattens_nested_aria_hash
        call_node = parse_call('a(href: "/", aria: { label: "Home" })')
        node = PhlexNode.build_tag(call_node)

        assert_equal(
          { "href" => "/", "aria-label" => "Home" },
          node.attributes
        )
        assert(node.attribute?("aria-label"))
      end

      def test_build_tag_flattens_nested_data_hash
        call_node = parse_call(
          'div(data: { controller: "modal" })'
        )
        node = PhlexNode.build_tag(call_node)

        assert_equal({ "data-controller" => "modal" }, node.attributes)
      end

      def test_build_tag_flattens_nested_hash_with_dynamic_value
        call_node = parse_call(
          'a(href: "/", aria: { label: t(".close") })'
        )
        node = PhlexNode.build_tag(call_node)

        assert_equal({ "href" => "/", "aria-label" => true }, node.attributes)
        assert(node.attribute?("aria-label"))
      end

      def test_build_tag_flattens_nested_string_keys
        call_node = parse_call(
          'a(href: "/", "aria" => { "label" => "Home" })'
        )
        node = PhlexNode.build_tag(call_node)

        assert(node.attribute?("aria-label"))
      end

      def test_build_tag_converts_inner_underscores_to_dashes
        call_node = parse_call(
          'div(data: { auto_save: "true" })'
        )
        node = PhlexNode.build_tag(call_node)

        assert(node.attribute?("data-auto-save"))
      end

      def test_build_tag_flattens_deeply_nested_hash
        call_node = parse_call(
          'div(aria: { described: { by: "id" } })'
        )
        node = PhlexNode.build_tag(call_node)

        assert(node.attribute?("aria-described-by"))
      end

      def test_build_tag_handles_multiple_nested_entries
        call_node = parse_call(
          'a(aria: { label: "Home", labelledby: "id" })'
        )
        node = PhlexNode.build_tag(call_node)

        assert(node.attribute?("aria-label"))
        assert(node.attribute?("aria-labelledby"))
      end

      def test_text_content_false_by_default
        call_node = parse_call("a(href: \"/\")")
        node = PhlexNode.build_tag(call_node)

        refute(node.text_content?)
      end

      def test_text_content_when_set
        call_node = parse_call("a(href: \"/\")")
        node = PhlexNode.build_tag(call_node, text_content: true)

        assert(node.text_content?)
      end

      private

      def parse_call(code)
        Prism.parse(code).value.statements.body.first
      end
    end
  end
end
