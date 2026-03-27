# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestRule < Minitest::Test
      def test_name
        rule = Rule.new

        assert_equal("Rule", rule.name)
      end

      def test_name_with_subclass
        subclass = Class.new(Rule)
        stub_const(subclass, "A11y::Lint::Rules::ImgMissingAlt")

        rule = subclass.new

        assert_equal("ImgMissingAlt", rule.name)
      end

      def test_check
        rule = Rule.new

        assert_raises(NotImplementedError) { rule.check(nil) }
      end

      private

      def stub_const(klass, name)
        klass.define_singleton_method(:name) { name }
      end
    end
  end
end
