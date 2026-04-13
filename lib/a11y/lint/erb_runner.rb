# frozen_string_literal: true

require "nokogiri"

module A11y
  module Lint
    # Parses ERB templates and checks them against accessibility rules.
    class ErbRunner
      ERB_TAG = /<%.*?%>/m
      ERB_OUTPUT_TAG = /<%=\s*(.*?)\s*-?%>/m
      VOID_ELEMENTS = %w[
        area base br col embed hr img input
        link meta param source track wbr
      ].freeze

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
          next unless source_confirmed_element?(html, nokogiri_node.name)

          check_node(
            ErbNode.new(nokogiri_node: nokogiri_node, line: nokogiri_node.line)
          )
        end
      end

      def source_confirmed_element?(html, tag_name)
        VOID_ELEMENTS.include?(tag_name) || html.include?("</#{tag_name}>")
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
