# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    class PhlexRunner
      # Decides whether a Phlex tag block produces accessible text.
      # Stateless: only reads the given Prism block node and pre-collected
      # child tags.
      class BlockTextScanner
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

        def self.scan(block, children:, wrapper: false)
          new(block, children:, wrapper:).scan
        end

        # Public recognizer for a single Prism node — used by PhlexRunner
        # to inspect a tag's first positional argument, where Phlex emits
        # the value as text content (`a("Click", href: "/x")`).
        def self.text_emitting?(node)
          new(nil, children: []).text_emitting?(node)
        end

        def self.non_blank_string_literal?(node)
          case node
          when Prism::StringNode
            !node.unescaped.strip.empty?
          when Prism::InterpolatedStringNode
            node.parts.any? do |part|
              if part.is_a?(Prism::StringNode)
                !part.unescaped.strip.empty?
              else
                true
              end
            end
          else
            false
          end
        end

        def initialize(block, children:, wrapper: false)
          @block = block
          @children = children
          @wrapper = wrapper
        end

        def scan
          return false unless @block.is_a?(Prism::BlockNode)

          scan_for_text(@block) || @children.any?(&:text_content?)
        end

        def text_emitting?(node)
          auto_emitted_text?(node)
        end

        private

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
          return true if self.class.non_blank_string_literal?(node)
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
          if PhlexNode.html_tag?(name)
            # Inside a tag whose class signals an accessible-name wrapper
            # (e.g. `sr-only`), an ambiguous bare call — name matches an
            # HTML tag, no args, no block — is treated as a text-emitting
            # method call rather than an empty HTML element. Matches
            # author intent for patterns like `span(class: "sr-only") { label }`
            # where `label` is an instance method, not the `<label>` tag.
            return @wrapper && bare_call?(call)
          end
          return true if TEXT_CALLS.include?(name)

          # Lowercase receiverless calls (locals, helper methods) auto-emit
          # their return value. Capitalized names are Phlex components,
          # which emit their own HTML, not text.
          lowercase_name?(name)
        end

        def bare_call?(call)
          call.arguments.nil? && call.block.nil?
        end

        def conditional_container?(node)
          node.is_a?(Prism::IfNode) ||
            node.is_a?(Prism::UnlessNode) ||
            node.is_a?(Prism::BeginNode) ||
            node.is_a?(Prism::StatementsNode) ||
            node.is_a?(Prism::ElseNode) ||
            node.is_a?(Prism::ParenthesesNode)
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

        def text_call?(node)
          node.is_a?(Prism::CallNode) &&
            node.receiver.nil? &&
            TEXT_CALLS.include?(node.name.to_s)
        end
      end
    end
  end
end
