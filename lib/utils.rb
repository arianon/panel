require_relative 'config'

module Util
  class << self
    def threshold(value, thresholds)
      thresholds.to_a.reverse_each do |trip, out|
        return out if value >= trip
      end
    end

    def color_by_percentage(value)
      threshold value,
                0 => Color.green,
                25 => Color.cyan,
                50 => Color.yellow,
                75 => Color.red
    end

    def blink(even, odd)
      Time.now.to_i.even? ? even : odd
    end

    def foreground(color = '-')
      "%{F#{color}}"
    end

    def background(color = '-')
      "%{B#{color}}"
    end

    def wrap(string, fg = nil, bg = nil)
      string = foreground(fg) << string << foreground if fg
      string = background(bg) << string << background if bg
      string
    end
  end
end
