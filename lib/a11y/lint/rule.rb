# frozen_string_literal: true

module A11y
  module Lint
    # Base class for accessibility lint rules.
    class Rule
      def self.check(node)
        new(node).check
      end

      def self.rule_name
        name.split("::").last
      end

      def initialize(node)
        @node = node
      end

      def check
        raise NotImplementedError
      end
    end
  end
end
