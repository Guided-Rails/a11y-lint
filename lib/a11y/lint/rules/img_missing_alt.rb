# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that img tags include an alt attribute (WCAG 1.1.1).
      class ImgMissingAlt < Rule
        def check(node)
          return unless an_image_without_an_alt_attribute?(node)

          "img tag is missing an alt attribute (WCAG 1.1.1)"
        end

        private

        def an_image_without_an_alt_attribute?(node)
          node.tag_name == "img" && !node.attribute?("alt")
        end
      end
    end
  end
end
