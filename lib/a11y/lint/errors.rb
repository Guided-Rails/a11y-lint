# frozen_string_literal: true

module A11y
  module Lint
    class Error < StandardError; end

    # Raised when slim is not installed.
    class SlimLoadError < Error
      def initialize
        super(
          "a11y-lint needs the `slim` gem to lint .slim files. " \
          "Add `gem \"slim\"` to your Gemfile."
        )
      end
    end
  end
end
