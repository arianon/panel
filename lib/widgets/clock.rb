#!/usr/bin/ruby -wU

require_relative '../config'
require_relative '../xresources'
require_relative 'helpers/iconify'

class Clock
  C = CONFIG.clock

  def initialize
    @icon = Iconify[C.icon, Xresources[C.color]]
  end

  def monitor
    loop do
      yield
      sleep C.reload
    end
  end

  def to_s
    @icon + Time.now.strftime(C.format)
  end
end

if __FILE__ == $PROGRAM_NAME
  clock = Clock.new
  clock.monitor { puts clock }
end
