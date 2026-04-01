# frozen_string_literal: true

require "yaml"

module A11y
  module Lint
    # Loads and stores rule configuration from a YAML file.
    class Configuration
      DEFAULT_FILE = ".a11y-lint.yml"

      def initialize(config_hash = {})
        @config = config_hash
      end

      def self.load(path = nil)
        path ||= DEFAULT_FILE

        if File.exist?(path)
          config_hash = YAML.safe_load_file(path) || {}
          new(config_hash)
        else
          new
        end
      end

      def enabled?(rule_name)
        return true unless @config.key?(rule_name)

        @config.dig(rule_name, "Enabled") != false
      end
    end
  end
end
