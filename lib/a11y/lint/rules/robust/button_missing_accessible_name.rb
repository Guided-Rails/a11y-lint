# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that <button> elements with no text content or meaningful
      # child elements include an aria-label (WCAG 4.1.2).
      class ButtonMissingAccessibleName < Rule
        def check
          return if no_offense?

          "button tag is missing an accessible name " \
            "requires an aria-label (WCAG 4.1.2)"
        end

        private

        def no_offense?
          node.tag_name != "button" ||
            aria_label? ||
            node.text_content? ||
            child_image_has_alt?
        end

        def aria_label?
          node.attribute?("aria-label") || node.attribute?("aria_label")
        end

        def child_image_has_alt?
          node.children.any? do |child|
            child.tag_name == "img" && non_empty_alt?(child)
          end
        end

        def non_empty_alt?(child)
          alt = child.attributes["alt"]
          alt.is_a?(String) && !alt.strip.empty?
        end
      end
    end
  end
end
