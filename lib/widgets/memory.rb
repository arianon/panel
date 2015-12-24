#!/usr/bin/ruby -wU

require_relative '../config'
require_relative 'helpers/mkbar'

class Memory
  REGEX = /^(?:MemTotal|MemFree|Buffers|Cached):\s+(\d+) kB/
  C = CONFIG.memory

  def initialize
    @total, @free, @buffers, @cached = File.read('/proc/meminfo')
                                       .scan(REGEX)
                                       .flatten
                                       .map!(&:to_f)
                                       .map! { |n| n / 1024 }
  end

  def to_s
    "%{F#{C.color}}%{R} #{C.icon} %{R}%{F-} " <<
      (C.bar ? Mkbar[percentage, C.colored_bar?] : "#{percentage.to_i}%")
  end

  def free
    @free + @buffers + @cached
  end

  def used
    @total - free
  end

  def percentage
    (used / @total) * 100
  end

  def monitor
    loop do
      initialize
      yield
      sleep C.reload
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  memory = Memory.new
  memory.monitor { puts memory }
end
