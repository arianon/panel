Thread.abort_on_exception = true

require_relative 'config'

require_relative 'widgets/clock'
require_relative 'widgets/cpu'
require_relative 'widgets/memory'
require_relative 'widgets/mpc'
require_relative 'widgets/pulseaudio'

class Rubar
  C = CONFIG.lemonbar

  def initialize
    cmd = '| lemonbar '
    cmd << "-F '#{C.foreground}' -B '#{C.background}' "
    cmd << C.fonts.map { |f| "-f '#{f}' " }.join
    cmd << "-a #{C.clickable_areas}"

    @bar = open(cmd, 'w+')

    @widgets = {
      clock: Clock.new,
      cpu: CPU.new,
      memory: Memory.new,
      music: MPC.new,
      volume: PulseAudio.new
    }

    @format = parse(C.format)
  end

  def update!
    @bar.write format(@format, @widgets)
  rescue KeyError
    raise "The bar's format is malformed!"
  end

  def run
    @widgets.each_value do |widget|
      Thread.new { widget.monitor { update! } }
    end

    Thread.new { @bar.each_line { |n| system n } }
    sleep
  end

  private

  def parse(s)
    s.gsub!(/(\w+)/, '%{\1}')
      .sub!('|', '%%{c}')
      .sub!('|', '%%{r}') << " \n"
  end
end
