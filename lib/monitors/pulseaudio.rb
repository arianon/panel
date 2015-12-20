#!/usr/bin/ruby -wU

class PulseAudio
  attr_reader :volume, :muted
  alias_method :muted?, :muted

  def initialize
    pactl = `pactl list sinks`

    @volume = pactl[%r{^\s*Volume:.*/\s+(\d+)%\s+/}, 1].to_i
    @muted = pactl[/Mute: (yes|no)/, 1] == 'yes'
  end

  def monitor
    Thread.new do
      yield(self)
      open('| pactl subscribe change').each_line do |line|
        # Respond only to sink changes
        if line.include? 'sink'
          update!
          yield(self)
        end
      end
    end
  end

  def update!
    initialize
    system 'pactl set-sink-volume 0 100%' if @volume > 100
  end

  def to_s
    "#{@volume}:#{@muted ? 'on' : 'off'}"
  end
end

if __FILE__ == $PROGRAM_NAME
  trap('INT') { exit }

  @pa = PulseAudio.new

  @pa.monitor do
    puts @pa
  end

  sleep
end
