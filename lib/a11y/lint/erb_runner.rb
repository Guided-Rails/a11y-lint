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
          line = source[0...match.begin(0)].count("\n") + 1
          check_node(
            build_erb_output_node(source, code, line, match.end(0))
          )
        end
      end

      def build_erb_output_node(source, code, line, match_end)
        block_body_codes, block_has_text =
          extract_block_info(source, code, match_end)

        ErbNode.new(
          ruby_code: code, line: line,
          block_body_codes: block_body_codes,
          block_has_text_children: block_has_text
        )
      end

      def extract_block_info(source, code, match_end)
        return [nil, false] unless code.match?(/\s+do\s*\z/)

        rest = source[match_end..]
        end_match = rest.match(/<%-?\s*end\s*-?%>/m)
        return [nil, false] unless end_match

        block_content = rest[0...end_match.begin(0)]
        codes = block_content.scan(ERB_OUTPUT_TAG).map { |m| m[0].strip }
        text_only = block_content.gsub(ERB_TAG, "").strip

        [codes, !text_only.empty?]
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
