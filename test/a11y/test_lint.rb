# frozen_string_literal: true

require "test_helper"

module A11y
  class TestLint < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::A11y::Lint::VERSION
    end
  end
end
