# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module A11y
  module Lint
    class TestConfiguration < Minitest::Test
      def test_all_rules_enabled_by_default
        config = Configuration.new

        assert(config.enabled?("ImgMissingAlt"))
        assert(config.enabled?("ImageTagMissingAlt"))
        assert(config.enabled?("MissingAccessibleName"))
      end

      def test_disable_a_rule
        config = Configuration.new("ImgMissingAlt" => { "Enabled" => false })

        refute(config.enabled?("ImgMissingAlt"))
        assert(config.enabled?("ImageTagMissingAlt"))
      end

      def test_explicitly_enable_a_rule
        config = Configuration.new("ImgMissingAlt" => { "Enabled" => true })

        assert(config.enabled?("ImgMissingAlt"))
      end

      def test_unconfigured_rules_are_enabled
        config = Configuration.new("ImgMissingAlt" => { "Enabled" => false })

        assert(config.enabled?("SomeOtherRule"))
      end

      def test_load_from_yaml_file
        Dir.mktmpdir do |dir|
          path = File.join(dir, ".a11y-lint.yml")
          File.write(path, "ImgMissingAlt:\n  Enabled: false\n")

          config = Configuration.load(path)

          refute(config.enabled?("ImgMissingAlt"))
          assert(config.enabled?("ImageTagMissingAlt"))
        end
      end

      def test_load_returns_default_when_file_missing
        config = Configuration.load("/nonexistent/.a11y-lint.yml")

        assert(config.enabled?("ImgMissingAlt"))
      end

      def test_load_handles_empty_yaml_file
        Dir.mktmpdir do |dir|
          path = File.join(dir, ".a11y-lint.yml")
          File.write(path, "")

          config = Configuration.load(path)

          assert(config.enabled?("ImgMissingAlt"))
        end
      end
    end
  end
end
