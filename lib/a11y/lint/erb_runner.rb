# frozen_string_literal: true

require "nokogiri"

module A11y
  module Lint
    # Parses ERB templates and checks them against accessibility rules.
    class ErbRunner
      ERB_TAG = /<%.*?%>/m
      ERB_OUTPUT_TAG = /<%=\s*(.*?)\s*-?%>/m

      def initialize(rules)
        @rules = rules
      end

      def run(source, filename:)
        @filename = filename
        @offenses = []

        check_html_nodes(source)
        check_erb_output_tags(source)

        @offenses
      end

      private

      attr_reader :rules

      def check_html_nodes(source)
        html = source.gsub(ERB_TAG, "")
        doc = Nokogiri::HTML4::DocumentFragment.parse(html)

        doc.traverse do |nokogiri_node|
          next unless nokogiri_node.element?

          node = ErbNode.new(nokogiri_node: nokogiri_node,
                             line: nokogiri_node.line)
          check_node(node)
        end
      end

      def check_erb_output_tags(source)
        source.scan(ERB_OUTPUT_TAG) do
          match = Regexp.last_match
          code = match[1]
          line_number = source[0...match.begin(0)].count("\n") + 1
          node = ErbNode.new(ruby_code: code, line: line_number)
          check_node(node)
        end
      end

      def check_node(node)
        rules.each do |rule|
          message = rule.check(node)
          next unless message

          @offenses << Offense.new(
            rule: rule.name,
            filename: @filename,
            line: node.line,
            message: message
          )
        end
      end
    end
  end
end
