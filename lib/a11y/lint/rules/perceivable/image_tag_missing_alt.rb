# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that image_tag calls include an alt option (WCAG 1.1.1).
      class ImageTagMissingAlt < NodeRule
        def check
          return if no_offense?

          "image_tag is missing an alt option (WCAG 1.1.1)"
        end

        private

        def no_offense?
          !image_tag || image_tag.keyword?(:alt)
        end

        def image_tag
          @image_tag ||= node.call_node&.find("image_tag")
        end
      end
    end
  end
end
