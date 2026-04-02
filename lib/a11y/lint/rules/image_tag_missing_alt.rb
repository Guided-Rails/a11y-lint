# frozen_string_literal: true

require "ripper"

module A11y
  module Lint
    module Rules
      # Checks that image_tag calls include an alt option (WCAG 1.1.1).
      class ImageTagMissingAlt < Rule
        def check(node)
          return unless an_image_tag_without_an_alt_attribute?(node)

          "image_tag is missing an alt option (WCAG 1.1.1)"
        end

        private

        def an_image_tag_without_an_alt_attribute?(node)
          code = node.ruby_code
          return false unless code

          sexp = Ripper.sexp(code)
          return false unless sexp

          call = extract_image_tag_call(sexp)
          call && !alt_key_within?(call)
        end

        def extract_image_tag_call(sexp)
          return unless sexp.is_a?(Array)
          return sexp if image_tag_call?(sexp)

          sexp.each do |child|
            result = extract_image_tag_call(child)
            return result if result
          end

          nil
        end

        def image_tag_call?(sexp)
          case sexp
          in [:command, [:@ident, "image_tag", *], *] then true
          in [:method_add_arg, [:fcall, [:@ident, "image_tag", *]], *] then true
          else false
          end
        end

        def alt_key_within?(sexp)
          return true if alt_key?(sexp)
          return false unless sexp.is_a?(Array)

          sexp.any? { |child| alt_key_within?(child) }
        end

        def alt_key?(sexp)
          return false unless sexp.is_a?(Array) && sexp[0] == :assoc_new

          key = sexp[1]
          (key in [:@label, "alt:", *]) ||
            (key in [:string_literal,
                     [:string_content,
                      [:@tstring_content, "alt", *]]])
        end
      end
    end
  end
end
