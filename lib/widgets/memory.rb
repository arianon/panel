#!/usr/bin/ruby -wU

module Memory
  REGEX = /^(?:MemTotal|MemFree|Buffers|Cached):\s+(\d+) kB/

  def self.readmemory
    File.read('/proc/meminfo')
      .scan(REGEX)
      .flatten
      .map!(&:to_f)
      .map! { |n| n / 1024 }
  end

  def self.free
    readmemory[1..-1].inject(:+)
  end

  def self.used
    readmemory.inject(:-)
  end

  def self.percentage
    tmp = readmemory
    (tmp.inject(:-) / tmp.first) * 100
  end

  def self.monitor(rate = 0.5)
    Thread.new do
      loop do
        yield self
        sleep rate
      end
    end
  end
end
