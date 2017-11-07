# frozen_string_literal: true

require "tzinfo"

require "boppers/uptime/version"
require "boppers/uptime/relative_time"

module Boppers
  class Uptime
    FORMAT = "%Y-%m-%dT%H:%M:%S%:z"

    attr_reader :name, :url, :interval, :status, :contain, :min_failures,
                :timezone, :format, :failures, :failed_at

    def initialize(name:, url:, interval: 30, status: 200, contain: nil,
                   min_failures: 1, timezone: Time.now.getlocal.zone,
                   format: FORMAT)
      @name = name
      @url = url
      @interval = interval
      @status = [status].flatten.map(&:to_i)
      @contain = contain
      @min_failures = min_failures
      @timezone = find_timezone(timezone)
      @format = format
      @failures = []
    end

    def call
      response = HttpClient.get(url)

      succeed = valid_response?(response)

      return succeed! if succeed

      # Check failed, so track the failure and check
      # if we need to send any notification (only sends a notification
      # when threadshold is reached for the first time).
      failures << now
      reached_threshold = failures.size == min_failures
      went_offline! if reached_threshold
    end

    def succeed!
      offline_at = failures.first
      online_at = now
      failure_threshold_exceeded = failures.size >= min_failures
      failures.clear
      back_online!(offline_at, online_at) if failure_threshold_exceeded
    end

    def valid_response?(response)
      validations = []

      validations << status.include?(response.code)
      validations << response.body.include?(contain) if contain.kind_of?(String)
      validations << response.body.match?(contain) if contain.kind_of?(Regexp)

      validations.all?
    end

    def back_online!(offline_at, online_at)
      duration = RelativeTime.call(offline_at, online_at)

      title = "#{name} is up"
      message = [
        "#{name} is back online at #{format_time(online_at)}, after #{duration} of downtime.",
        "You can check it at #{url}."
      ].join("\n")

      Boppers.notify(:uptime,
                     title: title,
                     message: message,
                     options: {color: :green})
    end

    def went_offline!
      failed_at = failures.first
      title = "#{name} is down"
      message = [
        "#{name} is offline since #{format_time(failed_at)}.",
        "You can check it at #{url}."
      ].join("\n")

      Boppers.notify(:uptime,
                     title: title,
                     message: message,
                     options: {color: :red})
    end

    def now
      period = timezone.current_period
      utc_offset = period.offset.utc_total_offset
      Time.now.getlocal(utc_offset)
    end

    def format_time(time)
      time.strftime(format)
    end

    def find_timezone(name)
      TZInfo::Timezone.get(name)
    rescue TZInfo::InvalidTimezoneIdentifier
      name = name.to_sym

      TZInfo::Timezone.all.find do |zone|
        zone.current_period.abbreviation == name
      end
    end
  end
end
