# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestCallNode < Minitest::Test
      def test_method_name
        call = parse('image_tag("photo.jpg")')

        result = call.method_name

        assert_equal("image_tag", result)
      end

      def test_keyword_with_symbol_key
        call = parse('image_tag("photo.jpg", alt: "A photo")')

        result = call.keyword?(:alt)

        assert(result)
      end

      def test_keyword_with_string_key
        call = parse('image_tag("photo.jpg", "alt" => "A photo")')

        result = call.keyword?(:alt)

        assert(result)
      end

      def test_keyword_returns_false_when_missing
        call = parse('image_tag("photo.jpg", class: "hero")')

        result = call.keyword?(:alt)

        refute(result)
      end

      def test_keyword_with_nested_hash
        call = parse('link_to("", "/path", aria: { label: "Go" })')

        result = call.keyword?(:aria, :label)

        assert(result)
      end

      def test_keyword_with_nested_hash_without_matching_inner_key
        call = parse('link_to("", aria: { describedby: "desc" })')

        result = call.keyword?(:aria, :label)

        refute(result)
      end

      def test_keyword_with_missing_outer_key
        call = parse('link_to("", "/path", class: "icon")')

        result = call.keyword?(:aria, :label)

        refute(result)
      end

      def test_keyword_with_string_aria_label
        call = parse('link_to("", "aria-label" => "Facebook")')

        result = call.keyword?(:"aria-label")

        assert(result)
      end

      def test_positional_args
        call = parse('link_to("Click", "/path", class: "btn")')

        result = call.positional_args

        assert_equal(2, result.length)
        assert_instance_of(Prism::StringNode, result[0])
        assert_instance_of(Prism::StringNode, result[1])
      end

      def test_positional_args_with_no_arguments
        call = parse("button_tag")

        result = call.positional_args

        assert_empty(result)
      end

      def test_first_positional_arg_empty_string
        call = parse('link_to("", "/path")')

        result = call.first_positional_arg_empty_string?

        assert(result)
      end

      def test_first_positional_arg_non_empty_string
        call = parse('link_to("Click", "/path")')

        result = call.first_positional_arg_empty_string?

        refute(result)
      end

      def test_first_positional_arg_empty_string_with_no_args
        call = parse("button_tag")

        result = call.first_positional_arg_empty_string?

        refute(result)
      end

      def test_block_true
        call = parse('link_to("#") do')

        result = call.block?

        assert(result)
      end

      def test_block_false
        call = parse('link_to("Click", "/path")')

        result = call.block?

        refute(result)
      end

      def test_find_returns_self_when_name_matches
        call = parse('image_tag("photo.jpg")')

        result = call.find("image_tag")

        assert_instance_of(CallNode, result)
        assert_equal("image_tag", result.method_name)
      end

      def test_find_returns_nested_call
        call = parse('link_to(image_tag("logo.svg"), root_path)')

        result = call.find("image_tag")

        assert_instance_of(CallNode, result)
        assert_equal("image_tag", result.method_name)
      end

      def test_find_returns_nil_when_not_found
        call = parse('link_to("Click", "/path")')

        result = call.find("image_tag")

        assert_nil(result)
      end

      def test_prism_node
        call = parse('image_tag("photo.jpg")')

        result = call.prism_node

        assert_instance_of(Prism::CallNode, result)
      end

      private

      def parse(code)
        RubyCode.new(code).call_node
      end
    end
  end
end
