# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestRubyCode < Minitest::Test
      def test_call_node_for_simple_method_call
        ruby_code = RubyCode.new('image_tag("photo.jpg")')

        result = ruby_code.call_node

        assert_instance_of(CallNode, result)
        assert_equal("image_tag", result.method_name)
      end

      def test_call_node_for_method_call_without_parentheses
        ruby_code = RubyCode.new('image_tag "photo.jpg", alt: "A photo"')

        result = ruby_code.call_node

        assert_instance_of(CallNode, result)
        assert_equal("image_tag", result.method_name)
      end

      def test_call_node_for_block_form
        ruby_code = RubyCode.new('link_to("#") do')

        result = ruby_code.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)

        assert(result.block?)
      end

      def test_call_node_for_multiline_code
        code = "link_to(\n    \"\",\n    \"/path\",\n    class: \"icon\",\n  )"
        ruby_code = RubyCode.new(code)

        result = ruby_code.call_node

        assert_instance_of(CallNode, result)
        assert_equal("link_to", result.method_name)
      end

      def test_call_node_returns_nil_for_nil
        ruby_code = RubyCode.new(nil)

        result = ruby_code.call_node

        assert_nil(result)
      end

      def test_call_node_returns_nil_for_empty_string
        ruby_code = RubyCode.new("")

        result = ruby_code.call_node

        assert_nil(result)
      end

      def test_call_node_returns_nil_for_non_method_code
        ruby_code = RubyCode.new("42")

        result = ruby_code.call_node

        assert_nil(result)
      end

      def test_call_node_skips_receivered_calls
        ruby_code = RubyCode.new("@user.name")

        result = ruby_code.call_node

        assert_nil(result)
      end

      def test_call_node_finds_nested_receiverless_call
        ruby_code = RubyCode.new('link_to(image_tag("logo.svg"), root_path)')

        result = ruby_code.call_node

        assert_equal("link_to", result.method_name)
      end
    end
  end
end
