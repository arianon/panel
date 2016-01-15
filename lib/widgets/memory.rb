#!/usr/bin/ruby -wU

require_relative '../config'
require_relative 'helpers/mkbar'
require_relative 'helpers/iconify'

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
    Iconify[C.icon, Xresources[C.color]] <<
      (C.bar ? Mkbar[percentage, C.bar == 'colored'] : format('%.1f%%', percentage))
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
