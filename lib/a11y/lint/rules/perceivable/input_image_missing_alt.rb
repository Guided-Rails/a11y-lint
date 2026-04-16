# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that <input type="image"> tags include an alt
      # attribute (WCAG 1.1.1).
      # https://www.w3.org/WAI/WCAG21/Techniques/html/H36
      class InputImageMissingAlt < NodeRule
        def check
          return unless an_input_image_without_an_alt_attribute?

          "input type=\"image\" is missing an alt attribute (WCAG 1.1.1)"
        end

        private

        def an_input_image_without_an_alt_attribute?
          node.tag_name == "input" &&
            node.attributes["type"] == "image" &&
            !node.attribute?("alt")
        end
      end
    end
  end
end
