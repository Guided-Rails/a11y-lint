# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    # Parses Phlex view classes and checks them
    # against accessibility rules.
    class PhlexRunner
      PHLEX_PATTERN = /\bdef\s+view_template\b/

      # Phlex auto-emits the return value of these calls into the document:
      # `plain` / `text` are built-in; the rest are registered as value
      # helpers by phlex-rails via `register_value_helper`.
      TEXT_CALLS = %w[
        plain text
        t translate l localize
        pluralize truncate
        number_to_currency number_to_human number_to_human_size
        number_to_percentage number_to_phone
        number_with_delimiter number_with_precision
        highlight excerpt
      ].to_set.freeze

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

      # A Phlex tag block produces accessible text if any statement
      # contains an explicit text marker (yield, plain/text/t/..., a
      # non-blank string literal), or if the block's last expression
      # auto-emits a value Phlex renders as text.
      def scan_for_text(block)
        statements = block_statements(block)
        return false if statements.empty?

        return true if statements.any? { |stmt| explicit_text?(stmt) }

        auto_emitted_text?(statements.last)
      end

      def block_statements(block)
        return [] unless block.is_a?(Prism::BlockNode)

        body = block.body
        body.is_a?(Prism::StatementsNode) ? body.body : []
      end

      def explicit_text?(node)
        return false if node.nil?
        return true if node.is_a?(Prism::YieldNode)
        return true if non_blank_string_literal?(node)
        return text_call?(node) if node.is_a?(Prism::CallNode)

        # Recurse only into conditional/grouping nodes — descending into
        # call args would treat string literals like `foo("bar")`'s "bar"
        # as block text, which it isn't.
        return false unless conditional_container?(node)

        node.child_nodes.compact.any? { |c| explicit_text?(c) }
      end

      def auto_emitted_text?(node)
        return false if node.nil?
        return true if explicit_text?(node)

        case node
        when Prism::LocalVariableReadNode
          true
        when Prism::CallNode
          auto_emitted_call?(node)
        when Prism::IfNode, Prism::UnlessNode
          if_branch_lasts(node).any? { |last| auto_emitted_text?(last) }
        end
      end

      def auto_emitted_call?(call)
        return true if call.receiver

        name = call.name.to_s
        return false if PhlexNode.html_tag?(name)
        return true if TEXT_CALLS.include?(name)

        # Lowercase receiverless calls (locals, helper methods) auto-emit
        # their return value. Capitalized names are Phlex components,
        # which emit their own HTML, not text.
        lowercase_name?(name)
      end

      def conditional_container?(node)
        node.is_a?(Prism::IfNode) ||
          node.is_a?(Prism::UnlessNode) ||
          node.is_a?(Prism::BeginNode) ||
          node.is_a?(Prism::StatementsNode) ||
          node.is_a?(Prism::ElseNode) ||
          node.is_a?(Prism::ParenthesesNode)
      end

      def non_blank_string_literal?(node)
        case node
        when Prism::StringNode
          !node.unescaped.strip.empty?
        when Prism::InterpolatedStringNode
          interpolated_string_non_blank?(node)
        else
          false
        end
      end

      def interpolated_string_non_blank?(node)
        node.parts.any? do |part|
          if part.is_a?(Prism::StringNode)
            !part.unescaped.strip.empty?
          else
            true
          end
        end
      end

      def lowercase_name?(name)
        first = name[0]
        first && first == first.downcase && first != first.upcase
      end

      def if_branch_lasts(node)
        if_branch_statements(node).flat_map do |stmts|
          stmts.is_a?(Prism::StatementsNode) ? [stmts.body.last].compact : []
        end
      end

      def if_branch_statements(node)
        branches = [node.statements]
        collect_else_branches(if_else_clause(node), branches)
        branches.compact
      end

      def collect_else_branches(current, branches)
        while current.is_a?(Prism::IfNode) || current.is_a?(Prism::UnlessNode)
          branches << current.statements
          current = if_else_clause(current)
        end
        branches << current.statements if current.is_a?(Prism::ElseNode)
      end

      def if_else_clause(node)
        case node
        when Prism::IfNode then node.subsequent
        when Prism::UnlessNode then node.else_clause
        end
      end

      def analyze_helper_block(call_node)
        block = call_node.block
        return [nil, false] unless block.is_a?(Prism::BlockNode)

        codes = []
        has_text = scan_block_content(block, codes)
        [codes.empty? ? nil : codes, has_text]
      end

      def scan_block_content(node, codes)
        node.child_nodes.compact.each do |child|
          next if skip_block_child?(child)
          return true if block_child_text?(child)
          next if tag_call?(child)
          next codes << child.slice if receiverless_call?(child)
          return true if scan_block_content(child, codes)
        end
        false
      end

      def skip_block_child?(child)
        tag_call?(child) && hidden_wrapper_tag?(child)
      end

      def block_child_text?(child)
        child.is_a?(Prism::YieldNode) ||
          non_blank_string_literal?(child) ||
          (tag_call?(child) && child.block)
      end

      def walk_block(block)
        return unless block.is_a?(Prism::BlockNode)

        block.child_nodes.compact.each { |c| walk(c) }
      end

      def tag_call?(node)
        receiverless_call?(node) && PhlexNode.html_tag?(node.name.to_s)
      end

      def text_call?(node)
        receiverless_call?(node) && TEXT_CALLS.include?(node.name.to_s)
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
