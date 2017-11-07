# frozen_string_literal: true

require "test_helper"

class BoppersUptimeTest < Minitest::Test
  test "lints bopper" do
    bopper = Boppers::Uptime.new(name: "Example", url: "http://example.com")
    Boppers::Testing::BopperLinter.call(bopper)
  end

  test "notifies when status is different than expected" do
    bopper = Boppers::Uptime.new(name: "Example", url: "http://example.com")
    time = bopper.now
    title = "Example is down"
    message = [
      "Example is offline since #{bopper.format_time(time)}.",
      "You can check it at http://example.com."
    ].join("\n")

    stub_request(:get, "http://example.com")
      .to_return(status: 500)

    bopper.stubs(:now).returns(time)
    Boppers
      .expects(:notify)
      .with(:uptime, title: title, message: message, options: {color: :red})

    bopper.call
  end

  test "succeeds when status matches" do
    stub_request(:get, "http://example.com")
      .to_return(status: 200)

    Boppers.expects(:notify).never

    bopper = Boppers::Uptime.new(name: "Example", url: "http://example.com")
    bopper.call
  end

  test "notifies when failures threadshold is reached" do
    stub_request(:get, "http://example.com")
      .to_return(status: 500)

    Boppers.expects(:notify).once

    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 min_failures: 3)
    3.times { bopper.call }
  end

  test "notifies when text is not found on response" do
    stub_request(:get, "http://example.com")
      .to_return(status: 200, body: "Error")

    Boppers.expects(:notify).once

    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 contain: "OK")
    bopper.call
  end

  test "succeeds when text is found on response" do
    stub_request(:get, "http://example.com")
      .to_return(status: 200, body: "OK")

    Boppers.expects(:notify).never

    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 contain: "OK")
    bopper.call
  end

  test "notifies when regexp is not found on response" do
    stub_request(:get, "http://example.com")
      .to_return(status: 200, body: "Error")

    Boppers.expects(:notify).once

    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 contain: /OK/)
    bopper.call
  end

  test "succeeds when regexp is found on response" do
    stub_request(:get, "http://example.com")
      .to_return(status: 200, body: "OK")

    Boppers.expects(:notify).never

    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 contain: /ok/i)
    bopper.call
  end

  test "resets failures when following request succeeds" do
    stub_request(:get, "http://example.com")
      .to_return([{status: 500}, {status: 200}])

    Boppers.expects(:notify).never

    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 min_failures: 2)

    bopper.call
    refute_empty bopper.failures

    bopper.call
    assert_empty bopper.failures
  end

  test "notifies when site get back online" do
    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com")
    time = bopper.now
    calls = []

    stub_request(:get, "http://example.com")
      .to_return([{status: 500}, {status: 200}])

    bopper.stubs(:now).returns(time)

    Boppers
      .expects(:notify)
      .twice
      .with {|*args| calls << args }

    2.times { bopper.call }

    name, kwargs = calls.last
    message = [
      "Example is back online at #{bopper.format_time(time)}, after 0 seconds of downtime.",
      "You can check it at http://example.com."
    ].join("\n")

    assert_equal :uptime, name
    assert_equal "Example is up", kwargs[:title]
    assert_equal message, kwargs[:message]
    assert_equal Hash[color: :green], kwargs[:options]
  end

  test "formats time in given timezone" do
    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 timezone: "America/Sao_Paulo")
    call = nil
    time = bopper.now
    tz = bopper.timezone.current_period.dst? ? "-02:00" : "-03:00"

    stub_request(:get, "http://example.com")
      .to_return(status: 500)

    bopper.stubs(:now).returns(time)

    Boppers
      .expects(:notify)
      .with {|*args| call = args }

    bopper.call

    assert call[1][:message].include?(tz)
  end

  test "uses custom time format" do
    bopper = Boppers::Uptime.new(name: "Example",
                                 url: "http://example.com",
                                 format: "FORMAT")
    call = nil

    stub_request(:get, "http://example.com")
      .to_return(status: 500)

    Boppers
      .expects(:notify)
      .with {|*args| call = args }

    bopper.call

    assert call[1][:message].include?("since FORMAT.")
  end

  [
    SocketError,
    Timeout::Error,
    Net::OpenTimeout
  ].each do |exception|
    test "intercepts #{exception}" do
      bopper = Boppers::Uptime.new(name: "Example",
                                   url: "http://example.com",
                                   format: "FORMAT")
      call = nil

      stub_request(:get, "http://example.com")
        .to_raise(exception)

      Boppers
        .expects(:notify)
        .with {|*args| call = args }

      bopper.call

      assert call[1][:title].include?("Example is down")
    end
  end
end
