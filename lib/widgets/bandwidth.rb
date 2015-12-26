#!/usr/bin/ruby -wU
# coding: utf-8

require_relative '../config'
require_relative 'helpers/mkbar'

# This is the worst widget class in the whole program.
# I'm sorry.

class Bandwidth
  C = CONFIG.bandwidth

  def initialize
    @icon_down = "%{F#{C.colors[0]}}%{R} #{C.icons[0]} %{R}%{F-}"
    @icon_up = "%{F#{C.colors[1]}}%{R} #{C.icons[1]} %{R}%{F-}"

    @rx = 0.0
    @tx = 0.0
    @time = 0.0

    @percentage = C.percentage
    @bar = C.percentage && C.percentage.bar rescue nil
    @colored = @bar == 'colored'

    @downspeed = 0.0
    @upspeed = 0.0

    if C.percentage
      @downperc = 0.0
      @upperc = 0.0
    end

    update!
  end

  def to_s
    if @percentage
      if @bar
        "#{@icon_down} #{Mkbar[@downperc, @colored]} #{@icon_up} #{Mkbar[@upperc, @colored]}"
      else
        "#{@icon_down} #{@downperc.to_i}% #{@icon_up} #{@upperc.to_i}%"
      end
    else
      "#{@icon_down} #{@downspeed.to_i / 1024}K #{@icon_up} #{@upspeed.to_i / 1024}K"
    end
  end

  def update!
    tmp = File.readlines('/proc/net/dev')[2].split

    @rx = tmp[1].to_f
    @tx = tmp[9].to_f
    @time = Time.now.to_f
  end

  def speed!
    prev_rx = @rx
    prev_tx = @tx
    prev_time = @time

    sleep C.reload
    update!

    delta_t = @time - prev_time
    down = (@rx - prev_rx) / delta_t
    up = (@tx - prev_tx) / delta_t

    @downspeed = down
    @upspeed = up
  end

  def percentage!
    speed!
    begin
      maxdown, maxup = @percentage.maxes
    rescue NoMethodError
      raise "You must define a 'maxes' key in the 'percentage hash'"
    end

    down = (@downspeed / maxdown) * 100
    up = (@upspeed / maxup) * 100

    @downperc = down
    @upperc = up
  end

  def monitor
    loop do
      yield
      update!
      if @percentage
        percentage!
      else
        speed!
      end
    end
  end
end
