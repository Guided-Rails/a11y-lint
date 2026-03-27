# frozen_string_literal: true

module A11y
  module Lint
    # Represents a single accessibility violation found by a lint rule.
    class Offense
      attr_reader :rule, :filename, :line, :message

      def initialize(rule:, filename:, line:, message:)
        @rule = rule
        @filename = filename
        @line = line
        @message = message
      end
    end
  end
end
