require 'test_helper'

module Mongoid
  class TimeDemongoizeStringTest < Workarea::TestCase
    def test_time_demongoize_accepts_iso8601_string
      value = '2026-02-25T01:23:48.719Z'

      result = ::Time.demongoize(value)

      assert(result.present?)
      assert_respond_to(result, :to_time)
      assert_kind_of(::Time, result.to_time)

      # Ensure we parsed the value, not returned the original string.
      refute_equal(value, result)

      # Best-effort normalization check.
      assert_match(/\A2026-02-25T01:23:48(\.719)?Z\z/, result.to_time.utc.iso8601(3))
    end
  end
end
