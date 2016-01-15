#!/usr/bin/ruby -wU

require_relative '../config'
require_relative '../xresources'
require_relative 'helpers/mkbar'
require_relative 'helpers/iconify'

class CPU
  C = CONFIG.cpu

  def initialize
    @perc = 0.0
    @icon = Iconify[C.icon, Xresources[C.color]]
    update!
  end

  def to_s
    widget = ''
    widget << @icon

    if C.bar
      widget << Mkbar[@perc, C.bar == 'colored']
    else
      widget << format('%.1f%%', @perc)
    end
  end

  def monitor
    loop do
      yield
      prev_used = @used
      prev_total = @total
      sleep C.reload
      update!
      @perc = (prev_used - @used) * 100 / (prev_total - @total)
    end
  end

  def update!
    tmp = open('/proc/stat', &:gets).split[1..-1].map!(&:to_f)
    @used = tmp[0] + tmp[2] # used = user+system
    @total = @used + tmp[3]  # total = used+idle
  end
end

if __FILE__ == $PROGRAM_NAME
  cpu = CPU.new
  cpu.monitor { puts cpu }
end
