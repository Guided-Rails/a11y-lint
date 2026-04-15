# frozen_string_literal: true

module A11y
  module Lint
    # Wraps a Slim AST s-expression as a queryable node for lint rules.
    class SlimNode
      attr_reader :line

      def initialize(sexp, line:)
        @sexp = sexp
        @line = line
      end

      def tag_name
        @sexp[2]
      end

      def ruby_code
        return unless slim_output?

        @sexp[3]
      end

      def call_node
        return unless slim_output?

        @call_node ||= parse_call_node
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def attributes
        @attributes ||= extract_attributes
      end

      # Returns direct HTML element children as SlimNode objects.
      # Walks through [:multi] and [:slim, :control] wrappers so that tags
      # nested inside control flow are still treated as direct children.
      # Opaque [:slim, :output] blocks are skipped.
      def children
        return [] unless html_tag?

        body = @sexp[4]
        collect_children(body)
      end

      # Returns ruby_code strings from child :slim :output nodes
      # inside a block body. Only meaningful for output nodes
      # (e.g. `= button_tag(...) do`).
      def block_body_codes
        return unless slim_output?

        collect_output_codes(@sexp[4])
      end

      # Returns true when the block body contains visible text or
      # HTML tag children (i.e. content that provides an accessible name).
      def block_has_text_children?
        return false unless slim_output?

        text_content?(@sexp[4])
      end

      private

      def html_tag?
        @sexp[0] == :html && @sexp[1] == :tag
      end

      def slim_output?
        @sexp[0] == :slim && @sexp[1] == :output
      end

      def parse_call_node
        RubyCode.new(@sexp[3]).call_node
      end

      def collect_output_codes(sexp)
        return [] unless sexp.is_a?(Array)
        return [sexp[3]] if slim_output_sexp?(sexp)

        sexp.flat_map { |child| collect_output_codes(child) }
      end

      def slim_output_sexp?(sexp)
        sexp.is_a?(Array) && sexp[0] == :slim && sexp[1] == :output
      end

      def text_content?(sexp)
        return false unless sexp.is_a?(Array)
        return true if slim_text_sexp?(sexp) || html_tag_sexp?(sexp)

        sexp.any? { |child| text_content?(child) }
      end

      def slim_text_sexp?(sexp)
        sexp[0] == :slim && sexp[1] == :text
      end

      def collect_children(sexp)
        return [] unless sexp.is_a?(Array)
        return [SlimNode.new(sexp, line: @line)] if html_tag_sexp?(sexp)
        return collect_children(sexp[3]) if slim_control_sexp?(sexp)
        return [] unless sexp[0] == :multi

        sexp[1..].flat_map { |c| collect_children(c) }
      end

      def html_tag_sexp?(sexp)
        sexp[0] == :html && sexp[1] == :tag
      end

      def slim_control_sexp?(sexp)
        sexp[0] == :slim && sexp[1] == :control
      end

      def extract_attributes
        return {} unless html_attributes?

        sexp_attributes[2..].each_with_object({}) do |attr_sexp, result|
          result[attr_sexp[2]] = true if html_attribute?(attr_sexp)
        end
      end

      def sexp_attributes
        @sexp[3]
      end

      def html_attributes?
        sexp_attributes.is_a?(Array) &&
          sexp_attributes[0] == :html &&
          sexp_attributes[1] == :attrs
      end

      def html_attribute?(attributes)
        attributes.is_a?(Array) &&
          attributes[0] == :html &&
          attributes[1] == :attr
      end
    end
  end
end
