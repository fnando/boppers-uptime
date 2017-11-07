# frozen_string_literal: true

module Boppers
  class Uptime
    module RelativeTime
      def self.call(from_time, to_time)
        seconds = (to_time - from_time).to_i
        return plural(seconds, "second") if seconds < 60

        minutes = (seconds / 60).to_i
        return plural(minutes, "minute") if minutes < 60

        hours = (minutes / 60).to_i
        return plural(hours, "hour") if hours < 24

        days = (hours / 24).to_i
        plural(days, "day")
      end

      def self.plural(count, one, many = "#{one}s")
        if count == 1
          "#{count} #{one}"
        else
          "#{count} #{many}"
        end
      end
    end
  end
end
