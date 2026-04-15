# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that image_tag calls include an alt option (WCAG 1.1.1).
      class ImageTagMissingAlt < Rule
        def check
          call = @node.call_node&.find("image_tag")
          return unless call
          return if call.has_keyword?(:alt)

          "image_tag is missing an alt option (WCAG 1.1.1)"
        end
      end
    end
  end
end
