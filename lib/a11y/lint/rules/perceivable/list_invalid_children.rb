# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that <ul> and <ol> only directly contain <li>, <script>,
      # or <template> elements (WCAG 1.3.1).
      class ListInvalidChildren < Rule
        LIST_TAGS = %w[ul ol].freeze
        ALLOWED_CHILDREN = %w[li script template].freeze

        def check
          return unless list_with_invalid_children?

          offense_message(@node.tag_name, invalid_children.first.tag_name)
        end

        private

        def list_with_invalid_children?
          LIST_TAGS.include?(@node.tag_name) && invalid_children.any?
        end

        def invalid_children
          @invalid_children ||= @node.children.reject do |child|
            ALLOWED_CHILDREN.include?(child.tag_name)
          end
        end

        def offense_message(parent, child)
          "<#{parent}> must only directly contain <li>, <script>, " \
            "or <template> elements, found <#{child}> (WCAG 1.3.1)"
        end
      end
    end
  end
end
