# frozen_string_literal: true

module A11y
  module Lint
    # Wraps a Slim AST s-expression as a queryable node for lint rules.
    class Node
      attr_reader :line

      def initialize(sexp, line:)
        @sexp = sexp
        @line = line
      end

      def tag_name
        @sexp[2]
      end

      def ruby_code
        return unless @sexp[0] == :slim && @sexp[1] == :output

        @sexp[3]
      end

      def attribute?(name)
        attributes.key?(name)
      end

      def attributes
        @attributes ||= extract_attributes
      end

      # Returns direct HTML element children as Node objects.
      # Walks through [:multi] and [:slim, :control] wrappers so that tags
      # nested inside control flow are still treated as direct children.
      # Opaque [:slim, :output] blocks are skipped.
      def children
        return [] unless html_tag?

        body = @sexp[4]
        collect_children(body)
      end

      private

      def html_tag?
        @sexp[0] == :html && @sexp[1] == :tag
      end

      def collect_children(sexp)
        return [] unless sexp.is_a?(Array)
        return [Node.new(sexp, line: @line)] if html_tag_sexp?(sexp)
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
