# frozen_string_literal: true

module A11y
  module Lint
    # Wraps a Nokogiri HTML element from an ERB template
    # as a queryable node for lint rules.
    class ErbElementNode
      attr_reader :line, :configuration

      def initialize(
        nokogiri_node:, line:, configuration: Configuration.new
      )
        @nokogiri_node = nokogiri_node
        @line = line
        @configuration = configuration
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
        return false if hidden_wrapper?(@nokogiri_node)

        visible_text_or_output?(@nokogiri_node)
      end

      # Returns direct element children wrapped as ErbElementNode objects.
      # Excludes elements whose class attribute matches a configured
      # hidden-wrapper class, since CSS-hidden subtrees do not contribute
      # to the accessible name.
      def children
        @nokogiri_node.element_children.filter_map do |child|
          next if hidden_wrapper?(child)

          ErbElementNode.new(
            nokogiri_node: child, line: child.line,
            configuration: configuration
          )
        end
      end

      private

      def visible_text_or_output?(node)
        return false if hidden_wrapper?(node)
        return true if own_text_or_marker?(node)

        node.element_children.any? { |c| visible_text_or_output?(c) }
      end

      def own_text_or_marker?(node)
        node.children.any? do |c|
          next false unless c.text?

          content = c.content
          content.include?(ErbRunner::ERB_OUTPUT_MARKER) ||
            !content.strip.empty?
        end
      end

      def hidden_wrapper?(node)
        classes = configuration.hidden_wrapper_classes
        return false if classes.empty?

        node_classes(node).any? { |klass| classes.include?(klass) }
      end

      def node_classes(node)
        return [] unless node.respond_to?(:attributes)

        value = node.attributes["class"]&.value
        value.is_a?(String) ? value.split : []
      end
    end
  end
end
