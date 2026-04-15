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

      def call_node
        @call_node ||= parse
      end

      private

      def parse
        source = @code.match?(/\s+do\s*\z/) ? "#{@code}\nend" : @code
        result = Prism.parse(source)
        return unless result.success?

        find_receiverless_call(result.value)
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
    end
  end
end
