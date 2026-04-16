# frozen_string_literal: true

module A11y
  module Lint
    # Base class for per-node accessibility lint rules.
    class NodeRule
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

      private

      attr_reader(:node)
    end
  end
end
