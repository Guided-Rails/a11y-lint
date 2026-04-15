# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    # Wraps a Nokogiri node or extracted ERB output tag
    # as a queryable node for lint rules.
    class ErbNode
      attr_reader :line, :block_body_codes

      def initialize(
        line:, nokogiri_node: nil, ruby_code: nil,
        block_body_codes: nil, block_has_text_children: false
      )
        @nokogiri_node = nokogiri_node
        @ruby_code_string = ruby_code
        @block_body_codes = block_body_codes
        @block_has_text_children = block_has_text_children
        @line = line
      end

      def tag_name
        @nokogiri_node&.name
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def attributes
        @attributes ||= extract_attributes
      end

      def ruby_code
        @ruby_code_string
      end

      def call_node
        return unless @ruby_code_string

        @call_node ||= parse_call_node
      end

      def block_has_text_children?
        @block_has_text_children
      end

      # Returns direct element children wrapped as ErbNode objects.
      def children
        return [] unless @nokogiri_node

        @nokogiri_node.element_children.map do |child|
          ErbNode.new(nokogiri_node: child, line: child.line)
        end
      end

      private

      def parse_call_node
        code = @ruby_code_string
        source = code.match?(/\s+do\s*\z/) ? "#{code}\nend" : code
        result = Prism.parse(source)
        return unless result.success?

        find_receiverless_call(result.value)
      end

      def find_receiverless_call(node)
        return node if node.is_a?(Prism::CallNode) && node.receiver.nil?

        node.child_nodes.compact.each do |child|
          found = find_receiverless_call(child)
          return found if found
        end
        nil
      end

      def extract_attributes
        return {} unless @nokogiri_node

        @nokogiri_node
          .attributes
          .each_with_object({}) do |(name, _attr), result|
            result[name] = true
        end
      end
    end
  end
end
