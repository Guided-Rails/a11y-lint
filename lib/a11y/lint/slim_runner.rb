# frozen_string_literal: true

module A11y
  module Lint
    # Parses Slim templates and checks them against accessibility rules.
    class SlimRunner
      def initialize(rules, template_rules: [])
        @rules = rules
        @template_rules = template_rules
      end

      def run(source, filename:)
        sexp = Slim::Parser.new.call(source)
        @line = 1
        @filename = filename
        @offenses = []
        @nodes = []
        walk(sexp)
        check_template_rules
        @offenses
      end

      private

      attr_reader(:rules)

      def walk(sexp)
        return unless node?(sexp)

        @line += 1 if sexp[0] == :newline
        new_node = Node.new(sexp, line: @line)
        if html_tag?(sexp) || slim_output?(sexp)
          @nodes << new_node
          check_node(new_node)
        end
        sexp.each { |child| walk(child) }
      end

      def html_tag?(sexp)
        sexp[0] == :html && sexp[1] == :tag
      end

      def slim_output?(sexp)
        sexp[0] == :slim && sexp[1] == :output
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

      def check_template_rules
        @template_rules.each do |rule|
          @offenses.concat(
            rule.check_template(
              filename: @filename, nodes: @nodes
            )
          )
        end
      end
    end
  end
end
