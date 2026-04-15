# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    # Represents a Ruby code string extracted from a template.
    # Parses the code once with Prism and exposes the resulting CallNode.
    # Used by SlimNode and ErbNode to avoid re-parsing in rules.
    class RubyCode
      def initialize(code)
        @code = code
      end

      # Returns the Prism::CallNode for the outermost receiverless
      # method call in the code, or nil if none exists.
      def call_node
        @call_node ||= parse
      end

      private

      attr_reader(:code)

      # Parses the code string into a Prism AST and returns the first
      # receiverless CallNode, or nil if the code is invalid or
      # contains no method calls (e.g. a plain variable or literal).
      def parse
        return unless prism_parse_result.success?

        find_receiverless_call(prism_parse_result.value)
      end

      # Walks the Prism AST to find the first method call without a
      # receiver (e.g. `link_to(...)` rather than `obj.link_to(...)`).
      # Rails helper calls in templates are always receiverless.
      def find_receiverless_call(node)
        return node if node.is_a?(Prism::CallNode) && node.receiver.nil?

        node.child_nodes.compact.each do |child|
          found = find_receiverless_call(child)
          return found if found
        end
        nil
      end

      # Prism.parse returns a Prism::ParseResult which contains the
      # AST (via .value) and whether the parse succeeded (via .success?).
      # The AST is always present since Prism does error-tolerant parsing.
      def prism_parse_result
        @prism_parse_result ||= Prism.parse(source)
      end

      # Slim/ERB block forms end with ` do` (e.g. `link_to("#") do`)
      # which isn't valid Ruby on its own. Appending `\nend` makes it
      # parseable and gives the resulting CallNode a `.block` attribute.
      def source
        if code.match?(/\s+do\s*\z/)
          "#{code}\nend"
        else
          code
        end
      end
    end
  end
end
