# frozen_string_literal: true

require "prism"

module A11y
  module Lint
    module Rules
      # Checks that link_to, external_link_to, and button_tag calls with
      # empty text or block content include an aria-label (WCAG 4.1.2).
      class MissingAccessibleName < Rule
        METHODS = %w[link_to external_link_to button_tag].freeze
        ICON_HELPERS = %w[inline_svg icon image_tag svg_icon].freeze

        def check
          call = find_matching_call
          return unless call
          return if aria_label?(call)
          return unless first_arg_empty_string?(call) ||
                        (call.block && icon_only_block?)

          offense_message(call.name.to_s)
        end

        private

        def find_matching_call
          return unless @node.call_node

          find_call(@node.call_node)
        end

        def offense_message(method_name)
          <<~MSG.strip
            #{method_name} missing an accessible name \
            requires an aria-label (WCAG 4.1.2)
          MSG
        end

        def find_call(node)
          if node.is_a?(Prism::CallNode) &&
             node.receiver.nil? &&
             METHODS.include?(node.name.to_s)
            return node
          end

          node.child_nodes.compact.each do |child|
            found = find_call(child)
            return found if found
          end
          nil
        end

        def first_arg_empty_string?(call)
          args = positional_args(call)
          return false unless args&.first

          first = args.first
          first.is_a?(Prism::StringNode) && first.unescaped.empty?
        end

        def positional_args(call)
          return unless call.arguments

          call.arguments.arguments.reject { |a| a.is_a?(Prism::KeywordHashNode) }
        end

        def icon_only_block?
          return false if @node.block_has_text_children?

          codes = @node.block_body_codes
          return true unless codes&.any?

          codes.all? { |c| icon_helper_call?(c) }
        end

        def icon_helper_call?(code)
          result = Prism.parse(code)
          return false unless result.success?

          stmt = result.value.statements.body.first
          stmt.is_a?(Prism::CallNode) &&
            stmt.receiver.nil? &&
            ICON_HELPERS.include?(stmt.name.to_s)
        end

        def aria_label?(call)
          keyword_hash = find_keyword_hash(call)
          return false unless keyword_hash

          keyword_hash.elements.any? { |assoc| aria_label_assoc?(assoc) }
        end

        def find_keyword_hash(call)
          return unless call.arguments

          call.arguments.arguments.find { |a| a.is_a?(Prism::KeywordHashNode) }
        end

        def aria_label_assoc?(assoc)
          name = key_name(assoc)

          if name == "aria" && assoc.value.is_a?(Prism::HashNode)
            assoc.value.elements.any? { |inner| key_name(inner) == "label" }
          else
            name == "aria-label"
          end
        end

        def key_name(assoc)
          return unless assoc.is_a?(Prism::AssocNode)

          case assoc.key
          when Prism::SymbolNode then assoc.key.unescaped
          when Prism::StringNode then assoc.key.unescaped
          end
        end
      end
    end
  end
end
