#!/usr/bin/ruby -wU

require_relative '../config'
require_relative 'helpers/mkbar'
require_relative 'helpers/respond_to'

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
    Iconify[C.icons[n], Xresources[C.colors[n]]]
  end

  def volume
    C.bar ? Mkbar[@volume, C.bar == 'colored'] : "#{@volume}%"
  end

  def to_s
    RespondTo[icon << volume, C.buttons]
  end

  def monitor
    yield
    IO.foreach('| pactl subscribe change') do |line|
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
