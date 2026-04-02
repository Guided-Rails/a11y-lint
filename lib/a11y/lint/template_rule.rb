# frozen_string_literal: true

module A11y
  module Lint
    # Base class for template-level accessibility lint rules.
    # Template rules inspect all nodes after the full template
    # has been walked, rather than checking one node at a time.
    class TemplateRule
      def self.rule_name
        name.split("::").last
      end

      def name
        self.class.name.split("::").last
      end

      def check_template(filename:, nodes:)
        raise NotImplementedError
      end
    end
  end
end
