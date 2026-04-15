# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    module Rules
      # Checks that image_tag calls include an alt option (WCAG 1.1.1).
      class ImageTagMissingAlt < Rule
        def check
          return unless an_image_tag_without_an_alt_attribute?

          "image_tag is missing an alt option (WCAG 1.1.1)"
        end

        private

        def an_image_tag_without_an_alt_attribute?
          call = find_image_tag_call
          call && !alt_keyword?(call)
        end

        def find_image_tag_call
          return unless @node.call_node

          find_call(@node.call_node, "image_tag")
        end

        def find_call(node, method_name)
          if node.is_a?(Prism::CallNode) &&
             node.receiver.nil? &&
             node.name.to_s == method_name
            return node
          end

          node.child_nodes.compact.each do |child|
            found = find_call(child, method_name)
            return found if found
          end
          nil
        end

        def alt_keyword?(call)
          keyword_hash = find_keyword_hash(call)
          return false unless keyword_hash

          keyword_hash.elements.any? { |assoc| key_name(assoc) == "alt" }
        end

        def find_keyword_hash(call)
          return unless call.arguments

          call.arguments.arguments.find { |arg| arg.is_a?(Prism::KeywordHashNode) }
        end

        def key_name(assoc)
          case assoc.key
          when Prism::SymbolNode then assoc.key.unescaped
          when Prism::StringNode then assoc.key.unescaped
          end
        end
      end
    end
  end
end
