# frozen_string_literal: true

module A11y
  module Lint
    # Base class for accessibility lint rules.
    class Rule
      def name
        self.class.name.split("::").last
      end

      def check(node)
        raise NotImplementedError
      end
    end
  end
end
