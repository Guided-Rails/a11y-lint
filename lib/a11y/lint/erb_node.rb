# frozen_string_literal: true

module A11y
  module Lint
    # Wraps a Nokogiri node or extracted ERB output tag
    # as a queryable node for lint rules.
    class ErbNode
      attr_reader :line

      def initialize(line:, nokogiri_node: nil, ruby_code: nil)
        @nokogiri_node = nokogiri_node
        @ruby_code_string = ruby_code
        @line = line
      end

      def tag_name
        @nokogiri_node&.name
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def attribute_value(name)
        attributes[name]
      end

      def attributes
        @attributes ||= extract_attributes
      end

      def ruby_code
        @ruby_code_string
      end

      # Returns direct element children wrapped as ErbNode objects.
      def children
        return [] unless @nokogiri_node

        @nokogiri_node.element_children.map do |child|
          ErbNode.new(nokogiri_node: child, line: child.line)
        end
      end

      private

      def extract_attributes
        return {} unless @nokogiri_node

        @nokogiri_node
          .attributes
          .transform_values(&:value)
      end
    end
  end
end
