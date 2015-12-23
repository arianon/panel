#!/usr/bin/ruby -wU
# coding: utf-8

module Bandwidth
  MAXDOWN = 172_000.0
  MAXUP = 65_536.0

  @prev = [0.0, 0.0, Time.now.to_f]
  @next = [0.0, 0.0, Time.now.to_f]

  def self.readbandwidth
    tmp = File.readlines('/proc/net/dev')[2].split

    received = tmp[1].to_i
    transmitted = tmp[9].to_i
    timestamp = Time.now.to_f

    [received, transmitted, timestamp]
  end

  def self.speed
    delta_t = @next[2] - @prev[2]
    down = (@next[0] - @prev[0]) / delta_t
    up = (@next[1] - @prev[1]) / delta_t

    [down, up]
  end

  def self.percentage
    downspd, upspd = speed

    down = (downspd / MAXDOWN) * 100
    up = (upspd / MAXUP) * 100

    [down, up]
  end

  def self.monitor(rate = 1)
    Thread.new do
      yield self

      loop do
        @prev = readbandwidth
        sleep rate
        @next = readbandwidth

        yield self
      end
    end
  end
end
