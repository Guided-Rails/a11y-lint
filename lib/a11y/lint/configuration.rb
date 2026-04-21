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

      def self.load(path = nil, search_path: Dir.pwd)
        path ||= find_config_file(search_path)
        return new unless path && File.exist?(path)

        config_hash = YAML.safe_load_file(path) || {}
        new(config_hash)
      end

      def self.find_config_file(start_dir)
        dir = File.expand_path(start_dir)
        dir = File.dirname(dir) unless File.directory?(dir)

        loop do
          candidate = File.join(dir, DEFAULT_FILE)
          return candidate if File.exist?(candidate)

          parent = File.dirname(dir)
          return nil if parent == dir

          dir = parent
        end
      end
      private_class_method :find_config_file

      def enabled?(rule_name)
        return true unless @config.key?(rule_name)

        @config.dig(rule_name, "Enabled") != false
      end

      def hidden_wrapper_classes
        @hidden_wrapper_classes ||=
          Array(@config["hidden_wrapper_classes"]).map(&:to_s).freeze
      end

      def enabled_rules
        Rules.constants.filter_map do |name|
          klass = Rules.const_get(name)
          next unless klass.is_a?(Class) && klass < NodeRule

          klass if enabled?(klass.rule_name)
        end
      end
    end
  end
end
