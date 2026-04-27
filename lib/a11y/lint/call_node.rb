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
      #   keyword?(:alt)                       => alt: or "alt" =>
      #   keyword?(:aria, :label)              => aria: { label: ... }
      #   keyword?(:"aria-label")              => "aria-label" =>
      #   keyword?(:input_html, :aria, :label) => 3-level nested hash
      def keyword?(*keys)
        return false unless (kw_hash = find_keyword_hash)

        nested_keyword_in?(kw_hash, keys)
      end

      # True when `key:` is present and its value is the symbol literal
      # `:expected` (e.g. `keyword_symbol?(:as, :select)` matches
      # `as: :select`).
      def keyword_symbol?(key, expected)
        return false unless (kw_hash = find_keyword_hash)

        assoc = kw_hash.elements.find { |a| key_name(a) == key.to_s }
        return false unless assoc&.value.is_a?(Prism::SymbolNode)

        assoc.value.unescaped == expected.to_s
      end

      # True when the `label:` keyword is present and its value is
      # `false` or an empty string literal — i.e. the helper is being
      # told to omit any visible label.
      def label_hidden?
        return false unless (kw_hash = find_keyword_hash)

        assoc = kw_hash.elements.find { |a| key_name(a) == "label" }
        return false unless assoc

        value = assoc.value
        value.is_a?(Prism::FalseNode) ||
          (value.is_a?(Prism::StringNode) && value.unescaped.empty?)
      end

      # True when the keyword is present AND its value is a non-empty
      # string literal OR any non-string expression (dynamic — can't be
      # statically proven empty, so treat as providing content).
      # False when the key is absent or the value is an empty string
      # literal.
      def keyword_non_empty?(key)
        return false unless (kw_hash = find_keyword_hash)

        assoc = kw_hash.elements.find { |a| key_name(a) == key.to_s }
        return false unless assoc

        value = assoc.value
        return !value.unescaped.empty? if value.is_a?(Prism::StringNode)

        true
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

      # Walks the (possibly nested) keyword hash following the given key
      # path. Each step except the last requires a HashNode value.
      def nested_keyword_in?(hash_node, keys)
        return false if keys.empty?

        head, *rest = keys
        assoc = hash_node.elements.find { |a| key_name(a) == head.to_s }
        return false unless assoc
        return true if rest.empty?
        return false unless assoc.value.is_a?(Prism::HashNode)

        nested_keyword_in?(assoc.value, rest)
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
