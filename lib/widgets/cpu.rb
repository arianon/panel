#!/usr/bin/ruby -wU

require_relative '../config'
require_relative 'helpers/mkbar'

class CPU
  C = CONFIG.cpu

  def initialize
    @perc = 0.0
    @icon = Iconify[C.icon, C.color]
    update!
  end

  def to_s
    if C.bar
      "#{@icon} #{Mkbar[@perc, C.bar == 'colored']}"
    else
      "#{@icon} #{@perc.round}%"
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
