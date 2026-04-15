# frozen_string_literal: true

module A11y
  module Lint
    # Wraps a Nokogiri node or extracted ERB output tag
    # as a queryable node for lint rules.
    class ErbNode
      include BlockInspection

      attr_reader(:block_body_codes, :line, :ruby_code)

      def initialize(
        line:,
        block_body_codes: nil,
        block_has_text_children: false,
        nokogiri_node: nil,
        ruby_code: nil
      )
        @line = line
        @block_body_codes = block_body_codes
        @block_has_text_children = block_has_text_children
        @nokogiri_node = nokogiri_node
        @ruby_code = ruby_code
      end

      def tag_name
        nokogiri_node&.name
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def attributes
        @attributes ||= extract_attributes
      end

      def call_node
        @call_node ||= RubyCode.new(ruby_code).call_node
      end

      def block_has_text_children?
        @block_has_text_children
      end

      # Returns direct element children wrapped as ErbNode objects.
      def children
        return [] unless nokogiri_node

        nokogiri_node.element_children.map do |child|
          ErbNode.new(nokogiri_node: child, line: child.line)
        end
      end

      private

      attr_reader(:nokogiri_node)

      def extract_attributes
        return {} unless nokogiri_node

        nokogiri_node
          .attributes
          .each_with_object({}) do |(name, _attr), result|
            result[name] = true
        end
      end
    end
  end
end
