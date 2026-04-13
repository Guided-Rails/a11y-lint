# frozen_string_literal: true

module A11y
  module Lint
    # Parses Slim templates and checks them against accessibility rules.
    class SlimRunner
      def initialize(rules)
        @rules = rules
      end

      def run(source, filename:)
        sexp = Slim::Parser.new.call(source)
        @line = 1
        @filename = filename
        @offenses = []
        walk(sexp)
        @offenses
      end

      private

      attr_reader(:rules)

      def walk(sexp)
        return unless node?(sexp)

        @line += 1 if sexp[0] == :newline
        new_node = Node.new(sexp, line: @line)
        check_node(new_node) if html_tag?(sexp) || slim_output?(sexp)
        @line += continuation_newlines(sexp)
        sexp.each { |child| walk(child) }
      end

      def html_tag?(sexp)
        sexp[0] == :html && sexp[1] == :tag
      end

      def slim_output?(sexp)
        sexp[0] == :slim && sexp[1] == :output
      end

      # Counts extra source lines consumed by backslash-continued
      # multiline expressions in :output and :control nodes.
      # Slim collapses these into one AST node whose ruby_code
      # string retains the original newlines.
      def continuation_newlines(sexp)
        code = case sexp
               in [:slim, :output, _, String => c, *] then c
               in [:slim, :control, String => c, *] then c
               else return 0
               end
        code.count("\n")
      end

      def node?(sexp)
        sexp.is_a?(Array) && !sexp.empty? && sexp[0].is_a?(Symbol)
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
