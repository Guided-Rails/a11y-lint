# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that image_submit_tag calls include an alt option (WCAG 1.1.1).
      # https://www.w3.org/WAI/WCAG21/Techniques/html/H36
      class ImageSubmitTagMissingAlt < NodeRule
        def check
          return if no_offense?

          "image_submit_tag is missing an alt option (WCAG 1.1.1)"
        end

        private

        def no_offense?
          !image_submit_tag || image_submit_tag.keyword?(:alt)
        end

        def image_submit_tag
          @image_submit_tag ||= node.call_node&.find("image_submit_tag")
        end
      end
    end
  end
end
