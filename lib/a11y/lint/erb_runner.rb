# frozen_string_literal: true

require "nokogiri"

module A11y
  module Lint
    # Parses ERB templates and checks them against accessibility rules.
    class ErbRunner
      ERB_TAG = /<%.*?%>/m
      ERB_OUTPUT_TAG = /<%=\s*(.*?)\s*-?%>/m
      ERB_OUTPUT_MARKER = "A11Y_LINT_ERB_OUTPUT"
      VOID_ELEMENTS = %w[
        area base br col embed hr img input
        link meta param source track wbr
      ].freeze

      def initialize(rules = nil, configuration: Configuration.new)
        @rules = rules || configuration.enabled_rules
        @configuration = configuration
      end

      def run(source, filename:)
        @filename = filename
        @offenses = []

        check_html_nodes(source)
        check_erb_output_tags(source)

        @offenses
      end

      private

      attr_reader :rules, :configuration

      def check_html_nodes(source)
        html = source.gsub(ERB_OUTPUT_TAG, ERB_OUTPUT_MARKER)
        html = html.gsub(ERB_TAG, "")
        doc = Nokogiri::HTML4::DocumentFragment.parse(html)

        doc.traverse do |nokogiri_node|
          next unless nokogiri_node.element?
          next unless source_confirmed_element?(html, nokogiri_node.name)

          node = build_erb_element_node(nokogiri_node)
          check_node(node)
        end
      end

      def build_erb_element_node(nokogiri_node)
        ErbElementNode.new(
          nokogiri_node: nokogiri_node,
          line: nokogiri_node.line,
          configuration: configuration
        )
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

        ErbOutputNode.new(
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
        visible_codes_and_text(block_content)
      end

      # Returns [visible_codes, visible_non_output_text?] where "visible"
      # means not inside a hidden-wrapper element (per configuration).
      def visible_codes_and_text(block_content)
        indexed_codes = []
        html = indexed_marker_html(block_content, indexed_codes)
        fragment = Nokogiri::HTML4::DocumentFragment.parse(html)
        strip_hidden_wrappers!(fragment)

        remaining = fragment.to_html
        visible_codes = indexed_codes.each_with_index.filter_map do |code, i|
          code if remaining.include?("#{ERB_OUTPUT_MARKER}#{i}_")
        end
        [visible_codes, non_marker_text?(remaining)]
      end

      def indexed_marker_html(block_content, codes)
        block_content.gsub(ERB_OUTPUT_TAG) do
          codes << Regexp.last_match(1).strip
          "#{ERB_OUTPUT_MARKER}#{codes.length - 1}_"
        end.gsub(ERB_TAG, "")
      end

      def non_marker_text?(html)
        !html.gsub(/#{ERB_OUTPUT_MARKER}\d+_/, "").strip.empty?
      end

      def strip_hidden_wrappers!(node)
        return if configuration.hidden_wrapper_classes.empty?

        node.element_children.each do |child|
          if hidden_wrapper_element?(child)
            child.remove
          else
            strip_hidden_wrappers!(child)
          end
        end
      end

      def hidden_wrapper_element?(node)
        value = node.attributes["class"]&.value
        return false unless value.is_a?(String)

        classes = configuration.hidden_wrapper_classes
        value.split.any? { |klass| classes.include?(klass) }
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
