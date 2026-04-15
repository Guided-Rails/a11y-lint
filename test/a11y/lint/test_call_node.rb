# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestCallNode < Minitest::Test
      def test_method_name
        call = parse('image_tag("photo.jpg")')

        assert_equal("image_tag", call.method_name)
      end

      def test_has_keyword_with_symbol_key
        call = parse('image_tag("photo.jpg", alt: "A photo")')

        assert(call.has_keyword?(:alt))
      end

      def test_has_keyword_with_string_key
        code = 'image_tag("photo.jpg", "alt" => "A photo")'
        call = parse(code)

        assert(call.has_keyword?(:alt))
      end

      def test_has_keyword_returns_false_when_missing
        call = parse('image_tag("photo.jpg", class: "hero")')

        refute(call.has_keyword?(:alt))
      end

      def test_has_keyword_with_nested_hash
        code = 'link_to("", "/path", aria: { label: "Go" })'
        call = parse(code)

        assert(call.has_keyword?(:aria, :label))
      end

      def test_has_keyword_with_nested_hash_without_matching_inner_key
        code = 'link_to("", aria: { describedby: "desc" })'
        call = parse(code)

        refute(call.has_keyword?(:aria, :label))
      end

      def test_has_keyword_with_missing_outer_key
        call = parse('link_to("", "/path", class: "icon")')

        refute(call.has_keyword?(:aria, :label))
      end

      def test_has_keyword_with_string_aria_label
        code = 'link_to("", "aria-label" => "Facebook")'
        call = parse(code)

        assert(call.has_keyword?(:"aria-label"))
      end

      def test_positional_args
        code = 'link_to("Click", "/path", class: "btn")'
        call = parse(code)

        args = call.positional_args

        assert_equal(2, args.length)
        assert_instance_of(Prism::StringNode, args[0])
        assert_instance_of(Prism::StringNode, args[1])
      end

      def test_positional_args_with_no_arguments
        call = parse("button_tag")

        assert_empty(call.positional_args)
      end

      def test_first_positional_arg_empty_string
        call = parse('link_to("", "/path")')

        assert(call.first_positional_arg_empty_string?)
      end

      def test_first_positional_arg_non_empty_string
        call = parse('link_to("Click", "/path")')

        refute(call.first_positional_arg_empty_string?)
      end

      def test_first_positional_arg_empty_string_with_no_args
        call = parse("button_tag")

        refute(call.first_positional_arg_empty_string?)
      end

      def test_block_true
        call = parse('link_to("#") do')

        assert(call.block?)
      end

      def test_block_false
        call = parse('link_to("Click", "/path")')

        refute(call.block?)
      end

      def test_find_returns_self_when_name_matches
        call = parse('image_tag("photo.jpg")')

        found = call.find("image_tag")

        assert_instance_of(CallNode, found)
        assert_equal("image_tag", found.method_name)
      end

      def test_find_returns_nested_call
        code = 'link_to(image_tag("logo.svg"), root_path)'
        call = parse(code)

        found = call.find("image_tag")

        assert_instance_of(CallNode, found)
        assert_equal("image_tag", found.method_name)
      end

      def test_find_returns_nil_when_not_found
        call = parse('link_to("Click", "/path")')

        assert_nil(call.find("image_tag"))
      end

      def test_prism_node
        call = parse('image_tag("photo.jpg")')

        assert_instance_of(Prism::CallNode, call.prism_node)
      end

      private

      def parse(code)
        RubyCode.new(code).call_node
      end
    end
  end
end
