# frozen_string_literal: true

module A11y
  module Lint
    # Maps Phlex method names to their HTML tag equivalents.
    module PhlexTags
      # Phlex method names that map to a different HTML tag.
      TAG_ALIASES = {
        "ruby_element" => "ruby",
        "template_tag" => "template"
      }.freeze

      HTML_TAGS = Set.new(
        %w[
          a abbr address article aside b bdi bdo
          blockquote body br button caption cite code
          col colgroup data datalist dd del details dfn
          dialog div dl dt em embed fieldset figcaption
          figure footer form h1 h2 h3 h4 h5 h6 head
          header hgroup hr html i iframe img input ins
          kbd label legend li link main map mark menu
          meter nav noscript object ol optgroup option
          output p picture pre progress q rp rt
          ruby_element s samp script search section
          select slot small span strong style sub
          summary sup table tbody td template_tag
          textarea tfoot th thead time title tr u ul
          var video wbr
        ]
      ).freeze

      def html_tag?(method_name)
        HTML_TAGS.include?(method_name)
      end

      def html_tag_name(method_name)
        TAG_ALIASES.fetch(method_name, method_name)
      end
    end
  end
end
