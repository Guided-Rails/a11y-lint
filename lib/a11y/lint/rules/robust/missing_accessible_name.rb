# frozen_string_literal: true

require "ripper"

module A11y
  module Lint
    module Rules
      # Checks that link_to, external_link_to, and button_tag calls with
      # empty text or block content include an aria-label (WCAG 4.1.2).
      class MissingAccessibleName < Rule
        METHODS = %w[link_to external_link_to button_tag].freeze
        ICON_HELPERS = %w[inline_svg icon image_tag svg_icon].freeze

        def check
          return unless source_code

          call = parse_call(clean_source_code)
          return unless call
          return if aria_label_within?(call)
          return unless first_arg_empty_string?(call) ||
                        (block? && icon_only_block?)

          offense_message(call_method_name(call))
        end

        private

        def source_code
          @node.ruby_code
        end

        def clean_source_code
          source_code&.sub(/\s+do\s*\z/, "")
        end

        def block?
          source_code != clean_source_code
        end

        def offense_message(method_name)
          <<~MSG.strip
            #{method_name} missing an accessible name \
            requires an aria-label (WCAG 4.1.2)
          MSG
        end

        def parse_call(code)
          sexp = Ripper.sexp(code)
          return unless sexp

          extract_matching_call(sexp)
        end

        def extract_matching_call(sexp)
          return unless sexp.is_a?(Array)

          name = call_method_name(sexp)
          return sexp if name && METHODS.include?(name)

          sexp.each do |child|
            result = extract_matching_call(child)
            return result if result
          end

          nil
        end

        def call_method_name(sexp)
          case sexp
          in [:command, [:@ident, name, *], *]
            name
          in [:method_add_arg,
              [:fcall, [:@ident, name, *]], *]
            name
          else nil
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
          in [:method_add_arg, _,
             [:arg_paren, [:args_add_block, args, *]]]
            then args
          in [:method_add_arg, _, [:arg_paren, Array => args]] then args
          else nil
          end
        end

        def icon_only_block?
          return false if @node.block_has_text_children?

          codes = @node.block_body_codes
          return true unless codes&.any?

          codes.all? { |c| icon_helper_call?(c) }
        end

        def icon_helper_call?(code)
          sexp = Ripper.sexp(code)
          return false unless sexp

          sexp in [:program, [call]] or return false

          name = call_method_name(call)
          name && ICON_HELPERS.include?(name)
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
          sexp.is_a?(Array) &&
            sexp[0] == :assoc_new &&
            (sexp[1] in [:@label, "label:", *])
        end

        def aria_label_string_key?(sexp)
          return false unless sexp.is_a?(Array) && sexp[0] == :assoc_new

          sexp[1] in [:string_literal,
            [:string_content,
              [:@tstring_content, "aria-label", *]]]
        end
      end
    end
  end
end
