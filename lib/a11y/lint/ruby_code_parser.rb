# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    # Parses a Ruby code string into a Prism CallNode.
    # Shared by SlimNode and ErbNode to avoid re-parsing in rules.
    module RubyCodeParser
      private

      def parse_call_node_from(code)
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
    end
  end
end
