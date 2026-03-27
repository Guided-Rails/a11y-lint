# frozen_string_literal: true

require "slim"
require_relative "lint/version"
require_relative "lint/offense"
require_relative "lint/node"
require_relative "lint/rule"
require_relative "lint/rules/img_missing_alt"
require_relative "lint/runner"

module A11y
  module Lint
    class Error < StandardError; end
  end
end
