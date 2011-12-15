# -*- encoding: utf-8 -*-

class Checker

  DAY = 86400

  # @param activity_count is a daily level of activities
  # @param last_time is the last time we checked
  def initialize( activity_count, last_time, check_time = Time.now )
    @activity_count = activity_count.to_i                     # e.g. 192 actions
    @last_time      = Time.at last_time.to_i                  # e.g. 1 hour ago
    @check_time     = check_time                              # e.g. now

    @last_time      = [ @check_time - DAY, @last_time ].max   # reject huge intervals like since epoch
    @interval       = @check_time - @last_time                # e.g. 1 hour

    # estimations
    variation       = 2 * ( rand + rand + rand + rand ) / 4   # ~1.0 more or less
    day_est         = variation * @activity_count             # e.g. ~192
    @estimate       = ( day_est * @interval / DAY ).to_i      # e.g. 8 (per hour)
    next_interval   = @estimate > 0 ? @interval / @estimate : @interval * 2
  end

  def checked( actual )
    @activity_count = ( actual * DAY / @interval ).to_i               # e.g. 12
    next_interval   = actual > 0 ? @interval / actual : @interval * 2 # e.g. 300 seconds (3600 / 12)
    @next_time      = @check_time + next_interval                     # e.g. now + 300 seconds
  end

  # refuse to check too often
  def check?
    @last_time < @check_time - 100
  end

  def activity_count
    @activity_count
  end

  def estimated_delay
    Math.sqrt(@estimate).to_i
  end

  def next_time
    # If not determined yet, calculate a safety time past the Facebook api limit
    @next_time ? @next_time : @check_time + 1000
  end
end
