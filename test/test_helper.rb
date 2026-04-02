# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "a11y/lint"

require "minitest/autorun"

module FixtureHelper
  FIXTURE_ROOT = File.expand_path(
    "fixtures", __dir__
  )

  def file_fixture(path)
    File.read(File.join(FIXTURE_ROOT, path))
  end
end

Minitest::Test.include(FixtureHelper)
