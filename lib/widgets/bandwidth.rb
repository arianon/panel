#!/usr/bin/ruby -wU
# coding: utf-8

require_relative '../config'
require_relative '../xresources'
require_relative 'helpers/mkbar'
require_relative 'helpers/iconify'

# This is the worst widget class in the whole program.
# I'm sorry.

class Bandwidth
  C = CONFIG.bandwidth

  def initialize
    @icon_down = Iconify[C.icons[0], Xresources[C.colors[0]]]
    @icon_up = Iconify[C.icons[1], Xresources[C.colors[1]]]

    @rx = 0.0
    @tx = 0.0
    @time = 0.0

    @maxupspeed = 1.0
    @maxdownspeed = 1.0

    @type = C.type
    @percentage = @type == 'percentage' || @type == 'bar' || @type == 'colored_bar'
    @colored = @type == 'colored_bar'

    @downspeed = 0.0
    @upspeed = 0.0

    if @percentage
      @downperc = 0.0
      @upperc = 0.0
    end

    update!
  end

  def to_s
    widget = ''

    widget << @icon_down

    case @type
    when /.*bar/
      widget << Mkbar[@downperc, @colored]
      widget << ' ' if CONFIG.reversed_icons
      widget << @icon_up
      widget << Mkbar[@upperc, @colored]
    when 'percentage'
      widget << format('%.1f', @downperc)
      widget << ' ' if CONFIG.reversed_icons
      widget << @icon_up
      widget << format('%.1f', @upperc)
    when 'kilobytes'
      widget << format('%dK', @downspeed / 1024)
      widget << ' ' if CONFIG.reversed_icons
      widget << @icon_up
      widget << format('%dK', @upspeed / 1024)
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

    @maxdownspeed = @downspeed if @downspeed > @maxdownspeed

    @maxupspeed = @upspeed if @upspeed > @maxupspeed

    down = (@downspeed / @maxdownspeed) * 100
    up = (@upspeed / @maxupspeed) * 100

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
