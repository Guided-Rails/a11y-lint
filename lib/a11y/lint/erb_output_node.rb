# frozen_string_literal: true

module A11y
  module Lint
    # Wraps an extracted ERB output tag (<%= ... %>)
    # as a queryable node for lint rules.
    class ErbOutputNode
      include BlockInspection

      attr_reader(:block_body_codes, :line, :ruby_code)

      def initialize(
        ruby_code:, line:,
        block_body_codes: nil, block_has_text_children: false
      )
        @ruby_code = ruby_code
        @line = line
        @block_body_codes = block_body_codes
        @block_has_text_children = block_has_text_children
      end

      def tag_name
        nil
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def attributes
        {}
      end

      def call_node
        @call_node ||= RubyCode.new(ruby_code).call_node
      end

      def block_has_text_children?
        @block_has_text_children
      end

      def children
        []
      end
    end
  end
end
