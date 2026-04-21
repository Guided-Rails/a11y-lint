# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    # Parses Phlex view classes and checks them
    # against accessibility rules.
    class PhlexRunner
      PHLEX_PATTERN = /\bdef\s+view_template\b/

      def initialize(rules, configuration: Configuration.new)
        @rules = rules
        @configuration = configuration
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

      attr_reader :rules, :configuration

      def walk(node)
        if receiverless_call?(node)
          process_call(node)
        else
          node.child_nodes.compact.each { |c| walk(c) }
        end
      end

      def process_call(node)
        if PhlexNode.html_tag?(node.name.to_s)
          check_tag(node)
        else
          check_helper(node)
        end
      end

      def check_tag(node)
        children = collect_block_children(node.block)
        has_text = tag_block_has_text?(node.block, children)
        check_node(
          PhlexNode.build_tag(
            node,
            children: children,
            text_content: has_text,
            configuration: configuration
          )
        )
      end

      def check_helper(node)
        codes, has_text = analyze_helper_block(node)
        helper = PhlexNode.build_helper(
          node,
          block_body_codes: codes,
          block_has_text_children: has_text,
          configuration: configuration
        )
        check_node(helper)
        walk_block(node.block)
      end

      def collect_block_children(block)
        return [] unless block.is_a?(Prism::BlockNode)

        [].tap { |c| gather_children(block, c) }
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
        has_text = tag_block_has_text?(child.block, kids)
        tag = PhlexNode.build_tag(
          child, children: kids, text_content: has_text,
                 configuration: configuration
        )
        check_node(tag)
        result << tag unless hidden_wrapper_tag?(child)
      end

      def hidden_wrapper_tag?(call_node)
        classes = configuration.hidden_wrapper_classes
        return false if classes.empty?

        tag_class_values(call_node).any? { |klass| classes.include?(klass) }
      end

      def tag_class_values(call_node)
        return [] unless call_node.arguments

        PhlexNode.kwarg_class_values(call_node)
      end

      def tag_block_has_text?(block, children)
        return false unless block.is_a?(Prism::BlockNode)

        scan_for_text(block) || children.any?(&:text_content?)
      end

      def scan_for_text(node)
        node.child_nodes.compact.any? do |child|
          text_call?(child) || child.is_a?(Prism::YieldNode) ||
            (!receiverless_call?(child) && scan_for_text(child))
        end
      end

      def analyze_helper_block(call_node)
        block = call_node.block
        return [nil, false] unless block.is_a?(Prism::BlockNode)

        codes = []
        has_text = scan_block_content(block, codes)
        [codes.empty? ? nil : codes, has_text]
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def scan_block_content(node, codes)
        node.child_nodes.compact.each do |child|
          next if tag_call?(child) && hidden_wrapper_tag?(child)
          return true if child.is_a?(Prism::YieldNode)
          return true if tag_call?(child) && child.block
          next if tag_call?(child)
          next codes << child.slice if receiverless_call?(child)
          return true if scan_block_content(child, codes)
        end
        false
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      def walk_block(block)
        return unless block.is_a?(Prism::BlockNode)

        block.child_nodes.compact.each { |c| walk(c) }
      end

      def tag_call?(node)
        receiverless_call?(node) && PhlexNode.html_tag?(node.name.to_s)
      end

      def text_call?(node)
        receiverless_call?(node) && node.name.to_s == "plain"
      end

      def receiverless_call?(node)
        node.is_a?(Prism::CallNode) && node.receiver.nil?
      end

      def check_node(node)
        rules.each do |rule_class|
          message = rule_class.check(node)
          next unless message

          @offenses << Offense.new(
            rule: rule_class.rule_name, filename: @filename,
            line: node.line, message: message
          )
        end
      end
    end
  end
end
