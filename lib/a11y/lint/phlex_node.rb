# frozen_string_literal: true

module A11y
  module Lint
    # Wraps a Phlex HTML tag call or helper method call
    # as a queryable node for lint rules.
    class PhlexNode
      include BlockInspection
      extend PhlexTags

      attr_reader(
        :attributes,
        :block_body_codes,
        :call_node,
        :children,
        :configuration,
        :line,
        :tag_name
      )

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        line:, tag_name: nil, attributes: {},
        call_node: nil, children: [],
        block_body_codes: nil,
        block_has_text_children: false,
        text_content: false,
        configuration: Configuration.new
      )
        @tag_name = tag_name
        @attributes = attributes
        @call_node = call_node
        @line = line
        @children = children
        @block_body_codes = block_body_codes
        @block_has_text_children = block_has_text_children
        @text_content = text_content
        @configuration = configuration
      end
      # rubocop:enable Metrics/ParameterLists

      def ruby_code
        nil
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def block_has_text_children?
        @block_has_text_children
      end

      def text_content?
        @text_content
      end

      def self.build_tag(
        call_node, children: [], text_content: false,
        configuration: Configuration.new
      )
        name = call_node.name.to_s
        new(
          tag_name: html_tag_name(name),
          attributes: extract_attributes(call_node),
          line: call_node.location.start_line,
          children: children,
          text_content: text_content,
          configuration: configuration
        )
      end

      def self.build_helper(
        call_node,
        block_body_codes: nil,
        block_has_text_children: false,
        configuration: Configuration.new
      )
        new(
          call_node: CallNode.new(call_node),
          line: call_node.location.start_line,
          block_body_codes: block_body_codes,
          block_has_text_children: block_has_text_children,
          configuration: configuration
        )
      end

      def self.kwarg_class_values(call_node)
        return [] unless call_node.arguments

        value = kwarg_nodes(call_node).find do |elem|
          kwarg_key(elem.key) == "class"
        end&.value

        value.is_a?(Prism::StringNode) ? value.unescaped.split : []
      end

      def self.extract_attributes(call_node)
        return {} unless call_node.arguments

        kwarg_nodes(call_node).each_with_object({}) do |elem, h|
          key = kwarg_key(elem.key)
          h[key] = kwarg_value(elem.value) if key
        end
      end

      def self.kwarg_nodes(call_node)
        args = call_node.arguments.arguments
        args.select { |a| a.is_a?(Prism::KeywordHashNode) }
            .flat_map { |a| a.elements.select { |e| e.is_a?(Prism::AssocNode) } }
      end

      def self.kwarg_key(key_node)
        case key_node
        when Prism::SymbolNode then key_node.value
        when Prism::StringNode then key_node.unescaped
        end
      end

      def self.kwarg_value(value_node)
        case value_node
        when Prism::StringNode then value_node.unescaped
        when Prism::SymbolNode then value_node.value
        else true
        end
      end

      private_class_method :kwarg_key, :kwarg_nodes, :kwarg_value,
                           :extract_attributes
    end
  end
end
