#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class MPC
  MPDError = Class.new(RuntimeError)

  def initialize
    @mpc = `mpc 2>/dev/null`
    fail MPDError, 'mpd is not running' if @mpc.empty?
  end

  def monitor
    Thread.new do
      # Yield ASAP then wait for mpc idleloop to re-init and yield again
      yield
      open('| mpc idleloop player options').each_line do
        update!
        yield
      end
    end
  end

  def song
    mpc = @mpc.split("\n")

    mpc.first if mpc.length > 1
  end

  def status
    @mpc[/playing|paused/].to_sym
  rescue
    :stopped
  end

  # TODO: Get rid of all this DRY
  def playing?
    status == :playing
  end

  def paused?
    status == :paused
  end

  def stopped?
    status == :stopped
  end

  def repeat?
    @mpc.include? 'repeat: on'
  end

  def random?
    @mpc.include? 'random: on'
  end

  def single?
    @mpc.include? 'single: on'
  end

  def consume?
    @mpc.include? 'consume: on'
  end

  def update!
    initialize
  end
end
