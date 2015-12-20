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

  %i(playing paused stopped).each do |state|
    define_method(:"#{state}?") { status == state }
  end

  %i(repeat random single consume).each do |mode|
    define_method(:"#{mode}?") { @mpc.include? '#{mode}: on' }
  end

  def update!
    initialize
  end
end
