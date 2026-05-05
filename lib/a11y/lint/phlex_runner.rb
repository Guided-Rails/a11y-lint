# frozen_string_literal: true

require "prism"
require_relative "phlex_runner/block_text_scanner"
require_relative "phlex_runner/phlex_call"

module A11y
  module Lint
    # Parses Phlex view classes and checks them
    # against accessibility rules.
    class PhlexRunner
      PHLEX_PATTERN = /\bdef\s+view_template\b/

      def initialize(rules = nil, configuration: Configuration.new)
        @rules = rules || configuration.enabled_rules
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
        if (call = PhlexCall.wrap(node))
          process_call(call)
        else
          node.child_nodes.compact.each { |c| walk(c) }
        end
      end

      def process_call(call)
        call.tag? ? check_tag(call) : check_helper(call)
      end

      def check_tag(call)
        children = collect_block_children(call.block_node)
        has_text = call.forwarded_block? ||
                   call.arg_has_text? ||
                   call.block_has_text?(children)
        check_node(
          PhlexNode.build_tag(
            call.call_node,
            children: children,
            text_content: has_text,
            configuration: configuration
          )
        )
      end

      def check_helper(call)
        codes, has_text = analyze_helper_block(call)
        helper = PhlexNode.build_helper(
          call.call_node,
          block_body_codes: codes,
          block_has_text_children: has_text,
          configuration: configuration
        )
        check_node(helper)
        walk_block(call.block_node)
      end

      def collect_block_children(block_node)
        return [] unless block_node

        [].tap { |c| gather_children(block_node, c) }
      end

      def gather_children(parent, result)
        parent.child_nodes.compact.each do |child|
          child_call = PhlexCall.wrap(child)
          if child_call&.tag?
            gather_tag_child(child_call, result)
          elsif child_call
            check_helper(child_call)
          else
            gather_children(child, result)
          end
        end
      end

      def gather_tag_child(call, result)
        kids = collect_block_children(call.block_node)
        has_text = call.arg_has_text? || call.block_has_text?(kids)
        tag = PhlexNode.build_tag(
          call.call_node, children: kids, text_content: has_text,
                          configuration: configuration
        )
        check_node(tag)
        result << tag unless hidden_wrapper_tag?(call)
      end

      def hidden_wrapper_tag?(call)
        classes = configuration.hidden_wrapper_classes
        return false if classes.empty?

        call.class_values.any? { |klass| classes.include?(klass) }
      end

      def analyze_helper_block(call)
        block = call.block_node
        return [nil, false] unless block

        codes = []
        has_text = scan_block_content(block, codes)
        [codes.empty? ? nil : codes, has_text]
      end

      def scan_block_content(node, codes)
        node.child_nodes.compact.each do |child|
          return true if visit_helper_block_child(child, codes)
        end
        false
      end

      def visit_helper_block_child(child, codes)
        child_call = PhlexCall.wrap(child)
        return handle_call_block_child(child_call, codes) if child_call

        block_child_text?(child) || scan_block_content(child, codes)
      end

      def handle_call_block_child(child_call, codes)
        return false if child_call.tag? && hidden_wrapper_tag?(child_call)
        return true if tag_call_has_text_block?(child_call)
        return false if child_call.tag?

        codes << child_call.call_node.slice
        false
      end

      def block_child_text?(child)
        child.is_a?(Prism::YieldNode) ||
          BlockTextScanner.non_blank_string_literal?(child)
      end

      def tag_call_has_text_block?(child_call)
        child_call.tag? && !child_call.block.nil?
      end

      def walk_block(block_node)
        return unless block_node

        block_node.child_nodes.compact.each { |c| walk(c) }
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
