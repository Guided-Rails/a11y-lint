# frozen_string_literal: true

module A11y
  module Lint
    # Wraps a Nokogiri HTML element from an ERB template
    # as a queryable node for lint rules.
    class ErbElementNode
      attr_reader :line

      def initialize(nokogiri_node:, line:, has_erb_output: false)
        @nokogiri_node = nokogiri_node
        @line = line
        @has_erb_output = has_erb_output
      end

      def tag_name
        @nokogiri_node.name
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def attributes
        @attributes ||=
          @nokogiri_node
          .attributes
          .transform_values(&:value)
      end

      def call_node
        nil
      end

      def ruby_code
        nil
      end

      def block_body_codes
        nil
      end

      def block_has_text_children?
        false
      end

      def text_content?
        @has_erb_output || !@nokogiri_node.text.strip.empty?
      end

      # Returns direct element children wrapped as ErbElementNode objects.
      def children
        @nokogiri_node.element_children.map do |child|
          ErbElementNode.new(nokogiri_node: child, line: child.line)
        end
      end
    end
  end
end
