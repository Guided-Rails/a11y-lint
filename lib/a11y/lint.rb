# frozen_string_literal: true

require "slim"
require "nokogiri"
require_relative "lint/version"
require_relative "lint/offense"
require_relative "lint/node"
require_relative "lint/erb_node"
require_relative "lint/configuration"
require_relative "lint/node_rule"
require_relative "lint/template_rule"
require_relative "lint/rules/perceivable/image_tag_missing_alt"
require_relative "lint/rules/perceivable/img_missing_alt"
require_relative "lint/rules/perceivable/list_invalid_children"
require_relative "lint/rules/robust/missing_accessible_name"
require_relative "lint/rules/operable/skip_navigation_link"
require_relative "lint/slim_runner"
require_relative "lint/erb_runner"

module A11y
  module Lint
    class Error < StandardError; end
  end
end
