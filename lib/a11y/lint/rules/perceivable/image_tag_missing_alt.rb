# frozen_string_literal: true

require "ripper"

module A11y
  module Lint
    module Rules
      # Checks that image_tag calls include an alt option (WCAG 1.1.1).
      class ImageTagMissingAlt < NodeRule
        def check
          return unless an_image_tag_without_an_alt_attribute?

          "image_tag is missing an alt option (WCAG 1.1.1)"
        end

        private

        def an_image_tag_without_an_alt_attribute?
          code = @node.ruby_code
          return false unless code

          sexp = Ripper.sexp(code)
          return false unless sexp

          call = extract_image_tag_call(sexp)
          call && !alt_key_within?(call)
        end

        # Walks the Ripper S-expression tree to find
        # the image_tag call node, if present.
        def extract_image_tag_call(sexp)
          return unless sexp.is_a?(Array)
          return sexp if image_tag_call?(sexp)

          sexp.each do |child|
            result = extract_image_tag_call(child)
            return result if result
          end

          nil
        end

        # Matches both calling styles:
        #   image_tag "photo.jpg"  => :command
        #   image_tag("photo.jpg") => :method_add_arg
        def image_tag_call?(sexp)
          case sexp
          in [:command, [:@ident, "image_tag", *], *] then true
          in [:method_add_arg, [:fcall, [:@ident, "image_tag", *]], *] then true
          else false
          end
        end

        # Recursively searches the sexp for an
        # :assoc_new node whose key is "alt".
        def alt_key_within?(sexp)
          return true if alt_key?(sexp)
          return false unless sexp.is_a?(Array)

          sexp.any? { |child| alt_key_within?(child) }
        end

        # Checks if a sexp is a hash pair (assoc_new)
        # with "alt" as the key.
        def alt_key?(sexp)
          return false unless sexp.is_a?(Array) && sexp[0] == :assoc_new

          alt_key_value?(sexp[1])
        end

        def alt_key_value?(key)
          alt_symbol_key?(key) || alt_string_key?(key)
        end

        # Matches symbol-style key: `alt: "..."`
        def alt_symbol_key?(key)
          key in [:@label, "alt:", *]
        end

        # Matches string-style key: `"alt" => "..."`
        def alt_string_key?(key)
          key in [
            :string_literal,
            [:string_content, [:@tstring_content, "alt", *]]
          ]
        end
      end
    end
  end
end
