# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestTemplateRule < Minitest::Test
      def test_name
        rule = TemplateRule.new

        assert_equal("TemplateRule", rule.name)
      end

      def test_name_with_subclass
        subclass = Class.new(TemplateRule)
        subclass.define_singleton_method(:name) do
          "A11y::Lint::Rules::SkipNavigationLink"
        end

        rule = subclass.new

        assert_equal("SkipNavigationLink", rule.name)
      end

      def test_check_template_raises_not_implemented
        rule = TemplateRule.new

        assert_raises(NotImplementedError) do
          rule.check_template(filename: "test.slim", nodes: [])
        end
      end
    end
  end
end
