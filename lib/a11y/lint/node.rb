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

      private

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
