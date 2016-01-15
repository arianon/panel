#!/usr/bin/ruby -wU

require_relative '../config'
require_relative 'helpers/iconify'
require_relative 'helpers/respond_to'

class MPC
  C = CONFIG.music

  MPDError = Class.new(RuntimeError)

  def initialize
    @mpc = `mpc 2>/dev/null`
    fail MPDError, 'mpd is not running' if @mpc.empty?
  end

  def song
    mpc = @mpc.split("\n")
    mpc.first if mpc.length > 1
  end

  def icon
    n = paused? ? 1 : 0
    Iconify[C.icons[n], Xresources[C.colors[n]]]
  end

  def to_s
    return '' if stopped?
    RespondTo[icon << song, C.buttons]
  end

  def status
    (@mpc[/playing|paused/] || 'stopped').to_sym
  end

  %i(playing paused stopped).each do |state|
    define_method(:"#{state}?") { status == state }
  end

  %i(repeat random single consume).each do |mode|
    define_method(:"#{mode}?") { @mpc.include? "#{mode}: on" }
  end

  def monitor
    yield
    IO.foreach('| mpc idleloop player options') do
      initialize
      yield
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  mpc = MPC.new
  mpc.monitor { puts mpc }
end
