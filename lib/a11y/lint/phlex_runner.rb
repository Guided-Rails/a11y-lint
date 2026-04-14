# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    # Parses Phlex view classes and checks them
    # against accessibility rules.
    class PhlexRunner
      PHLEX_PATTERN =
        /\bdef\s+view_template\b|class\s+\S+\s*<\s*Phlex::/

      def initialize(rules)
        @rules = rules
      end

      def run(source, filename:)
        return [] unless source.match?(PHLEX_PATTERN)

        @source = source
        @filename = filename
        @offenses = []

        walk(Prism.parse(source).value)
        @offenses
      end

      private

      attr_reader :rules

      def walk(node)
        if receiverless_call?(node)
          process_call(node)
        else
          node.child_nodes.compact.each { |c| walk(c) }
        end
      end

      def process_call(node)
        name = node.name.to_s
        if PhlexNode.html_tag?(name)
          check_tag(node)
        else
          check_helper(node)
        end
      end

      def check_tag(node)
        children = collect_block_children(node.block)
        check_node(PhlexNode.build_tag(node, children:))
      end

      def check_helper(node)
        check_node(PhlexNode.build_helper(node, @source))
        walk_block(node.block)
      end

      def collect_block_children(block)
        return [] unless block.is_a?(Prism::BlockNode)

        children = []
        gather_children(block, children)
        children
      end

      def gather_children(parent, result)
        parent.child_nodes.compact.each do |child|
          if tag_call?(child)
            gather_tag_child(child, result)
          elsif receiverless_call?(child)
            check_helper(child)
          else
            gather_children(child, result)
          end
        end
      end

      def gather_tag_child(child, result)
        kids = collect_block_children(child.block)
        node = PhlexNode.build_tag(child, children: kids)
        result << node
        check_node(node)
      end

      def walk_block(block)
        return unless block.is_a?(Prism::BlockNode)

        block.child_nodes.compact.each { |c| walk(c) }
      end

      def tag_call?(node)
        receiverless_call?(node) &&
          PhlexNode.html_tag?(node.name.to_s)
      end

      def receiverless_call?(node)
        node.is_a?(Prism::CallNode) && node.receiver.nil?
      end

      def check_node(node)
        rules.each do |rule_class|
          message = rule_class.check(node)
          next unless message

          @offenses << Offense.new(
            rule: rule_class.rule_name,
            filename: @filename,
            line: node.line,
            message: message
          )
        end
      end
    end
  end
end
