#!/usr/bin/ruby -wU

require_relative '../config'
require_relative 'helpers/mkbar'

class PulseAudio
  C = CONFIG.pulseaudio

  def initialize
    pactl = `pactl list sinks`
    @volume = pactl[/[0-9]+%/].to_i
    @muted = pactl[/Mute: (yes|no)/, 1] == 'yes'
    system 'pactl set-sink-volume 0 100%' if @volume > 100
  end

  def icon
    n = @muted ? 1 : 0
    "%{F#{C.colors[n]}}%{R} #{C.icons[n]} %{R}%{F-} "
  end

  def volume
    C.bar ? Mkbar[@volume, C.bar == 'colored'] : "#{@volume}%"
  end

  def to_s
    widget = ''
    buttons = C.buttons.to_h

    widget << buttons.map { |btn, cmd| "%{A#{btn}:#{cmd}:}" }.join
    widget << icon << volume
    widget << '%{A}' * buttons.size
  end

  def monitor
    yield
    open('| pactl subscribe change').each_line do |line|
      # Respond only to sink changes
      if line.include? 'sink'
        initialize
        yield
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  pulse = PulseAudio.new
  pulse.monitor { puts pulse }
end
