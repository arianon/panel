#!/usr/bin/ruby -wU

require_relative '../config'

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
    "%{F#{C.colors[n]}}%{R} #{C.icons[n]} %{R}%{F-} "
  end

  def to_s
    return '' if stopped?

    widget = ''
    buttons = C.buttons.to_h

    widget << buttons.map { |btn, cmd| "%{A#{btn}:#{cmd}:}" }.join
    widget << icon << song
    widget << '%{A}' * buttons.size
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
    open('| mpc idleloop player options').each_line do
      initialize
      yield
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  mpc = MPC.new
  mpc.monitor { puts mpc }
end
