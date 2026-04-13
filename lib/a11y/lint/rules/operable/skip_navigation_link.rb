# frozen_string_literal: true

module A11y
  module Lint
    module Rules
      # Checks that layout templates include a skip navigation
      # link (WCAG 2.4.1).
      class SkipNavigationLink < TemplateRule
        LAYOUT_PATTERN = %r{layouts/}

        def check_template(filename:, nodes:)
          return [] unless layout_file?(filename)
          return [] if skip_link_present?(nodes)

          [build_offense(filename)]
        end

        private

        def build_offense(filename)
          Offense.new(
            rule: name,
            filename: filename,
            line: 1,
            message: "Layout is missing a skip navigation link " \
                     "(WCAG 2.4.1). Add an anchor tag " \
                     '(e.g. <a href="#main-content">) near ' \
                     "the top of the layout."
          )
        end

        def layout_file?(filename)
          filename.match?(LAYOUT_PATTERN)
        end

        def skip_link_present?(nodes)
          nodes.any? { |node| skip_link?(node) }
        end

        def skip_link?(node)
          node.tag_name == "a" && anchor_href?(node)
        end

        def anchor_href?(node)
          href = node.attribute_value("href")
          href.is_a?(String) && href.start_with?("#")
        end
      end
    end
  end
end
