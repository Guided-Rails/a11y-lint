# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestRubyCode < Minitest::Test
      def test_call_node_for_simple_method_call
        ruby_code = RubyCode.new('image_tag("photo.jpg")')

        assert_instance_of(Prism::CallNode, ruby_code.call_node)
        assert_equal("image_tag", ruby_code.call_node.name.to_s)
      end

      def test_call_node_for_method_call_without_parentheses
        ruby_code = RubyCode.new('image_tag "photo.jpg", alt: "A photo"')

        assert_instance_of(Prism::CallNode, ruby_code.call_node)
        assert_equal("image_tag", ruby_code.call_node.name.to_s)
      end

      def test_call_node_for_block_form
        ruby_code = RubyCode.new('link_to("#") do')

        assert_instance_of(Prism::CallNode, ruby_code.call_node)
        assert_equal("link_to", ruby_code.call_node.name.to_s)
        refute_nil(ruby_code.call_node.block)
      end

      def test_call_node_for_multiline_code
        code = "link_to(\n    \"\",\n    \"/path\",\n    class: \"icon\",\n  )"
        ruby_code = RubyCode.new(code)

        assert_instance_of(Prism::CallNode, ruby_code.call_node)
        assert_equal("link_to", ruby_code.call_node.name.to_s)
      end

      def test_call_node_returns_nil_for_non_method_code
        ruby_code = RubyCode.new("42")

        assert_nil(ruby_code.call_node)
      end

      def test_call_node_skips_receivered_calls
        ruby_code = RubyCode.new('@user.name')

        assert_nil(ruby_code.call_node)
      end

      def test_call_node_finds_nested_receiverless_call
        ruby_code = RubyCode.new('link_to(image_tag("logo.svg"), root_path)')

        assert_equal("link_to", ruby_code.call_node.name.to_s)
      end
    end
  end
end
