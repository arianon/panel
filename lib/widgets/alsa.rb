require_relative '../config'
require_relative 'helpers/mkbar'
require_relative 'helpers/iconify'

class ALSA
  SCONTROL = 'Master'
  C = CONFIG.volume

  def initialize
    amixer = `amixer sget #{SCONTROL}`

    @volume = amixer[/\[(\d+)%\]/, 1].to_i
    @muted = amixer[/\[(on|off)\]/, 1] == 'off'
  end

  def icon
    n = @muted ? 1 : 0
    Iconify[C.icons[n], C.colors[n]]
  end

  def volume
    C.bar ? Mkbar[@volume] : "#{@volume}%"
  end

  def to_s
    widget = ''
    buttons = C.buttons.to_h

    widget << buttons.map { |btn, cmd| "%{A#{btn}:#{cmd}:}" }.join
    widget << icon << volume
    widget << '%{A}' * buttons.size
  end

  def monitor
    loop do
      yield
      sleep C.reload || 1
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  alsa = ALSA.new
  alsa.monitor { puts alsa }
end
