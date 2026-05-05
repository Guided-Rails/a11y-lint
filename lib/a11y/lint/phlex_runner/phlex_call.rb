# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    class PhlexRunner
      # Traversal-facing wrapper around a `Prism::CallNode` for the Phlex
      # pipeline. Centralises the Prism-shape inspection (receiverless?,
      # tag vs helper, block forms) so PhlexRunner#walk can read as
      # build wrapper -> classify -> recurse.
      #
      # Distinct from `PhlexNode`, which is the rule-facing node sharing
      # an interface with SlimNode/ErbNode.
      class PhlexCall
        # Returns a PhlexCall when `node` is a receiverless Prism call,
        # nil otherwise. Phlex tag/helper calls are always receiverless;
        # a `helpers.image_tag(...)` call has a receiver and is skipped.
        def self.wrap(node)
          return nil unless node.is_a?(Prism::CallNode)
          return nil unless node.receiver.nil?

          new(node)
        end

        def initialize(call_node)
          @call_node = call_node
        end

        attr_reader :call_node

        def name
          @call_node.name.to_s
        end

        def line
          @call_node.location.start_line
        end

        def tag?
          PhlexNode.html_tag?(name)
        end

        def helper?
          !tag?
        end

        def block
          @call_node.block
        end

        # The block as a Prism::BlockNode, or nil for `&block` forwards
        # and calls without a block.
        def block_node
          block.is_a?(Prism::BlockNode) ? block : nil
        end

        # `tag(&block)` defers content to the caller; we can't see what
        # they emit, so trust the wrapper rather than report a false
        # positive.
        def forwarded_block?
          block.is_a?(Prism::BlockArgumentNode)
        end

        def block_children
          block_node ? block_node.child_nodes.compact : []
        end

        def block_has_text?(children = [])
          BlockTextScanner.scan(block_node, children: children)
        end

        # Phlex's tag API emits the first positional argument as text
        # content (`a("Click me", href: "/x")` is equivalent to
        # `a(href: "/x") { "Click me" }`).
        def arg_has_text?
          arg = first_positional_arg
          return false if arg.nil?

          BlockTextScanner.text_emitting?(arg)
        end

        def first_positional_arg
          return nil unless @call_node.arguments

          @call_node.arguments.arguments.find do |arg|
            !arg.is_a?(Prism::KeywordHashNode) &&
              !arg.is_a?(Prism::BlockArgumentNode)
          end
        end

        def class_values
          PhlexNode.kwarg_class_values(@call_node)
        end
      end
    end
  end
end
