# frozen_string_literal: true

require "ripper"

module A11y
  module Lint
    module Rules
      # Checks that link_to / external_link_to calls with empty text
      # or block content include an aria-label (WCAG 4.1.2).
      class LinkMissingAccessibleName < Rule
        LINK_METHODS = %w[link_to external_link_to].freeze

        def check(node)
          code = node.ruby_code
          return unless code

          clean_code = code.sub(/\s+do\s*\z/, "")
          call = parse_link_call(clean_code)
          return unless call
          return if aria_label_within?(call)

          offense_message(call, block: clean_code != code)
        end

        private

        def offense_message(call, block:)
          if first_arg_empty_string?(call)
            "link with empty text content requires an aria-label (WCAG 4.1.2)"
          elsif block
            "link with block content requires an aria-label (WCAG 4.1.2)"
          end
        end

        def parse_link_call(code)
          sexp = Ripper.sexp(code)
          return unless sexp

          extract_link_call(sexp)
        end

        def extract_link_call(sexp)
          return unless sexp.is_a?(Array)
          return sexp if link_call?(sexp)

          sexp.each do |child|
            result = extract_link_call(child)
            return result if result
          end

          nil
        end

        def link_call?(sexp)
          case sexp
          in [:command, [:@ident, name, *], *] if LINK_METHODS.include?(name) then true
          in [:method_add_arg, [:fcall, [:@ident, name, *]], *] if LINK_METHODS.include?(name) then true
          else false
          end
        end

        def first_arg_empty_string?(call)
          args = extract_args(call)
          return false unless args&.first

          args.first in [:string_literal, [:string_content]]
        end

        def extract_args(call)
          case call
          in [:command, _, [:args_add_block, args, *]] then args
          in [:method_add_arg, _, [:arg_paren, [:args_add_block, args, *]]] then args
          in [:method_add_arg, _, [:arg_paren, Array => args]] then args
          else nil
          end
        end

        def aria_label_within?(sexp)
          return true if aria_hash_with_label?(sexp)
          return true if aria_label_string_key?(sexp)
          return false unless sexp.is_a?(Array)

          sexp.any? { |child| aria_label_within?(child) }
        end

        def aria_hash_with_label?(sexp)
          return false unless sexp.is_a?(Array) && sexp[0] == :assoc_new

          key = sexp[1]
          value = sexp[2]

          (key in [:@label, "aria:", *]) && label_key_within?(value)
        end

        def label_key_within?(sexp)
          return true if label_key?(sexp)
          return false unless sexp.is_a?(Array)

          sexp.any? { |child| label_key_within?(child) }
        end

        def label_key?(sexp)
          sexp.is_a?(Array) && sexp[0] == :assoc_new && (sexp[1] in [:@label, "label:", *])
        end

        def aria_label_string_key?(sexp)
          return false unless sexp.is_a?(Array) && sexp[0] == :assoc_new

          sexp[1] in [:string_literal, [:string_content, [:@tstring_content, "aria-label", *]]]
        end
      end
    end
  end
end
