# frozen_string_literal: true

require "test_helper"

class RelativeTimeTest < Minitest::Test
  def relative_time(from_time, to_time)
    Boppers::Uptime::RelativeTime.call(from_time, to_time)
  end

  test "returns relative time for seconds" do
    time = Time.now

    assert_equal "0 seconds", relative_time(time, time)
    assert_equal "1 second", relative_time(time, time + 1)
    assert_equal "59 seconds", relative_time(time, time + 59)
  end

  test "returns relative time for minutes" do
    time = Time.now

    assert_equal "1 minute", relative_time(time, time + 60)
    assert_equal "2 minutes", relative_time(time, time + 120)
    assert_equal "59 minutes", relative_time(time, time + 60 * 59)
  end

  test "returns relative time for hours" do
    time = Time.now

    assert_equal "1 hour", relative_time(time, time + 60 * 60)
    assert_equal "2 hours", relative_time(time, time + 60 * 120)
    assert_equal "23 hours", relative_time(time, time + 60 * 60 * 23)
  end

  test "returns relative time for days" do
    time = Time.now

    assert_equal "1 day", relative_time(time, time + 60 * 60 * 24)
    assert_equal "2 days", relative_time(time, time + 60 * 60 * 24 * 2)
    assert_equal "365 days", relative_time(time, time + 60 * 60 * 24 * 365)
  end
end
