# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestNodeRule < Minitest::Test
      def test_rule_name
        assert_equal("NodeRule", NodeRule.rule_name)
      end

      def test_rule_name_with_subclass
        subclass = Class.new(NodeRule)
        stub_const(subclass, "A11y::Lint::Rules::ImgMissingAlt")

        assert_equal("ImgMissingAlt", subclass.rule_name)
      end

      def test_check_class_method_dispatches_to_instance
        subclass = Class.new(NodeRule) do
          def check
            "saw #{@node}"
          end
        end

        assert_equal("saw a-node", subclass.check("a-node"))
      end

      def test_check_instance_method_raises_when_not_overridden
        assert_raises(NotImplementedError) { NodeRule.check(nil) }
      end

      private

      def stub_const(klass, name)
        klass.define_singleton_method(:name) { name }
      end
    end
  end
end
