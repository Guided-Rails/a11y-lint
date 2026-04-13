# frozen_string_literal: true

require "nokogiri"

module A11y
  module Lint
    # Parses ERB templates and checks them against accessibility rules.
    class ErbRunner
      ERB_TAG = /<%.*?%>/m
      ERB_OUTPUT_TAG = /<%=\s*(.*?)\s*-?%>/m

      def initialize(rules, template_rules: [])
        @rules = rules
        @template_rules = template_rules
      end

      def run(source, filename:)
        @filename = filename
        @offenses = []
        @nodes = []

        check_html_nodes(source)
        check_erb_output_tags(source)
        check_template_rules

        @offenses
      end

      private

      attr_reader :rules

      def check_html_nodes(source)
        doc = parse_html(source)

        doc.traverse do |nokogiri_node|
          next unless nokogiri_node.element?

          register_and_check(
            ErbNode.new(
              nokogiri_node: nokogiri_node,
              line: nokogiri_node.line
            )
          )
        end
      end

      def parse_html(source)
        Nokogiri::HTML4::DocumentFragment.parse(
          source.gsub(ERB_TAG, "")
        )
      end

      def check_erb_output_tags(source)
        source.scan(ERB_OUTPUT_TAG) do
          match = Regexp.last_match
          code = match[1]
          line = source[0...match.begin(0)].count("\n") + 1
          register_and_check(ErbNode.new(ruby_code: code, line:))
        end
      end

      def register_and_check(node)
        @nodes << node
        check_node(node)
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
