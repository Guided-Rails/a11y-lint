# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class PhlexRunner
      class TestPhlexCall < Minitest::Test
        def test_wrap_returns_call_for_receiverless_call
          node = parse_call("img(src: 'x.jpg')")

          assert_instance_of(PhlexCall, PhlexCall.wrap(node))
        end

        def test_wrap_returns_nil_for_call_with_receiver
          node = parse_call("helpers.image_tag('x.jpg')")

          assert_nil(PhlexCall.wrap(node))
        end

        def test_wrap_returns_nil_for_non_call_node
          tree = Prism.parse("x = 1").value

          assert_nil(PhlexCall.wrap(tree))
        end

        def test_name_returns_method_name
          call = wrap("a(href: '/x')")

          assert_equal("a", call.name)
        end

        def test_line_returns_start_line
          tree = Prism.parse("\nimg(src: 'x.jpg')\n").value
          call_node = first_call(tree)

          assert_equal(2, PhlexCall.new(call_node).line)
        end

        def test_tag_for_html_element
          assert_predicate(wrap("img(src: 'x.jpg')"), :tag?)
        end

        def test_tag_false_for_helper
          refute_predicate(wrap("link_to('x', '/y')"), :tag?)
        end

        def test_helper_inverse_of_tag
          assert_predicate(wrap("link_to('x', '/y')"), :helper?)
          refute_predicate(wrap("img(src: 'x.jpg')"), :helper?)
        end

        def test_block_node_returns_block_node_when_present
          call = wrap("a(href: '/x') { 'click' }")

          assert_instance_of(Prism::BlockNode, call.block_node)
        end

        def test_block_node_nil_when_no_block
          assert_nil(wrap("img(src: 'x.jpg')").block_node)
        end

        def test_block_node_nil_for_forwarded_block
          assert_nil(wrap("a(&block)").block_node)
        end

        def test_forwarded_block_true_for_block_argument
          assert_predicate(wrap("a(&block)"), :forwarded_block?)
        end

        def test_forwarded_block_false_for_block_node
          refute_predicate(wrap("a { 'click' }"), :forwarded_block?)
        end

        def test_forwarded_block_false_when_no_block
          refute_predicate(wrap("img(src: 'x.jpg')"), :forwarded_block?)
        end

        def test_block_has_text_true_for_explicit_string
          assert(wrap("a(href: '/x') { 'click' }").block_has_text?)
        end

        def test_block_has_text_false_for_empty_block
          refute(wrap("a(href: '/x') { }").block_has_text?)
        end

        def test_arg_has_text_true_for_string_positional
          assert_predicate(wrap("a('click', href: '/x')"), :arg_has_text?)
        end

        def test_arg_has_text_false_when_no_positional
          refute_predicate(wrap("a(href: '/x')"), :arg_has_text?)
        end

        def test_first_positional_arg_returns_string_node
          call = wrap("a('click', href: '/x')")

          assert_instance_of(Prism::StringNode, call.first_positional_arg)
        end

        def test_first_positional_arg_skips_keyword_hash
          assert_nil(wrap("a(href: '/x')").first_positional_arg)
        end

        def test_first_positional_arg_skips_block_argument
          assert_nil(wrap("a(&block)").first_positional_arg)
        end

        def test_class_values_returns_split_classes
          call = wrap("div(class: 'sr-only hidden')")

          assert_equal(%w[sr-only hidden], call.class_values)
        end

        def test_class_values_empty_when_no_arguments
          assert_empty(wrap("br").class_values)
        end

        def test_class_values_empty_when_no_class_kwarg
          assert_empty(wrap("a(href: '/x')").class_values)
        end

        def test_call_node_exposes_underlying_node
          node = parse_call("a(href: '/x')")
          call = PhlexCall.new(node)

          assert_same(node, call.call_node)
        end

        private

        def wrap(source)
          PhlexCall.wrap(parse_call(source))
        end

        def parse_call(source)
          first_call(Prism.parse(source).value)
        end

        def first_call(node)
          return node if node.is_a?(Prism::CallNode)

          node.child_nodes.compact.each do |child|
            found = first_call(child)
            return found if found
          end
          nil
        end
      end
    end
  end
end
