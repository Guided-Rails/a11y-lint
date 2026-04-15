# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    # Wraps a Prism::CallNode with a rule-friendly query API.
    class CallNode
      attr_reader :prism_node

      def initialize(prism_node)
        @prism_node = prism_node
      end

      def method_name
        @prism_node.name.to_s
      end

      # Checks for a keyword argument by name.
      #   keyword?(:alt)          => alt: or "alt" =>
      #   keyword?(:aria, :label) => aria: { label: ... }
      #   keyword?(:"aria-label") => "aria-label" =>
      def keyword?(*keys)
        return false unless (kw_hash = find_keyword_hash)

        if keys.length == 1
          flat_keyword?(kw_hash, keys[0])
        else
          nested_keyword?(kw_hash, keys[0], keys[1])
        end
      end

      def positional_args
        return [] unless @prism_node.arguments

        @prism_node.arguments.arguments.reject do |a|
          a.is_a?(Prism::KeywordHashNode)
        end
      end

      def first_positional_arg_empty_string?
        first = positional_args.first
        first.is_a?(Prism::StringNode) && first.unescaped.empty?
      end

      def block?
        !@prism_node.block.nil?
      end

      # Finds a receiverless call by method name in this node's
      # subtree (including self). Returns a CallNode or nil.
      def find(name)
        found = search_for_call(@prism_node, name)
        found ? self.class.new(found) : nil
      end

      private

      def flat_keyword?(kw_hash, key)
        kw_hash.elements.any? do |assoc|
          key_name(assoc) == key.to_s
        end
      end

      def nested_keyword?(kw_hash, outer_key, inner_key)
        assoc = kw_hash.elements.find do |a|
          key_name(a) == outer_key.to_s
        end
        return false unless assoc&.value.is_a?(Prism::HashNode)

        assoc.value.elements.any? do |inner|
          key_name(inner) == inner_key.to_s
        end
      end

      def find_keyword_hash
        return unless @prism_node.arguments

        @prism_node.arguments.arguments.find do |arg|
          arg.is_a?(Prism::KeywordHashNode)
        end
      end

      def key_name(assoc)
        return unless assoc.is_a?(Prism::AssocNode)

        case assoc.key
        when Prism::SymbolNode then assoc.key.unescaped
        when Prism::StringNode then assoc.key.unescaped
        end
      end

      def search_for_call(node, name)
        if node.is_a?(Prism::CallNode) &&
           node.receiver.nil? &&
           node.name.to_s == name
          return node
        end

        node.child_nodes.compact.each do |child|
          found = search_for_call(child, name)
          return found if found
        end
        nil
      end
    end
  end
end
