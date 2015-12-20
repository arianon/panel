class ALSA
  attr_reader :volume, :muted
  alias_method :muted?, :muted

  SCONTROL = 'Master'

  def initialize
    amixer = `amixer sget #{SCONTROL}`

    @volume = amixer[/\[(\d+)%\]/, 1].to_i
    @muted = amixer[/\[(on|off)\]/, 1] == 'off'
  end

  def set(vol)
    @volume = volume

    system "amixer -q sset #{SCONTROL} #{vol}% unmute"
  end

  def increase(vol)
    @volume += vol
    sign = vol > 0 ? '+' : '-'

    system "amixer -q sset #{SCONTROL} #{vol.abs}%#{sign} unmute"
  end

  def mute
    @muted = true
    system "amixer -q sset #{SCONTROL} mute"
  end

  def unmute
    @muted = false
    system "amixer -q sset #{SCONTROL} unmute"
  end

  def toggle
    @muted = !@muted
    system "amixer -q sset #{SCONTROL} toggle"
  end

  def update!
    initialize
  end

  def to_s
    "#{@volume}:#{@muted ? 'on' : 'off'}"
  end
end

if __FILE__ == $PROGRAM_NAME
  volume = ALSA.new

  volume.toggle
  volume.toggle
  volume.increase(-15)
  volume.increase(5)
  volume.set(100)
  puts volume
end
