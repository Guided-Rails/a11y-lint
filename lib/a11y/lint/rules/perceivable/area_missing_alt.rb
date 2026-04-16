# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that area tags include an alt attribute (WCAG 1.1.1).
      # https://www.w3.org/WAI/WCAG21/Techniques/html/H24
      class AreaMissingAlt < NodeRule
        def check
          return unless an_area_without_an_alt_attribute?

          "area tag is missing an alt attribute (WCAG 1.1.1)"
        end

        private

        def an_area_without_an_alt_attribute?
          node.tag_name == "area" && !node.attribute?("alt")
        end
      end
    end
  end
end
