#!/usr/bin/ruby -wU

module Cpu
  def self.readstat
    tmp = open('/proc/stat', &:gets).split[1..-1].map!(&:to_f)

    # used = user + system
    # total = used + idle
    used = tmp[0] + tmp[2]
    total = used + tmp[3]

    [used, total]
  end

  def self.report(wait)
    prev_used, prev_total = readstat
    sleep wait
    next_used, next_total = readstat

    (prev_used - next_used) * 100 / (prev_total - next_total)
  end

  def self.monitor(rate = 0.5)
    Thread.new do
      yield 0.0
      loop { yield report(rate) }
    end
  end
end
