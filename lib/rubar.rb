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

    @clock = Clock.new
    @cpu = CPU.new
    @memory = Memory.new
    @music = MPC.new
    @volume = PulseAudio.new

    @widgets = [@clock, @cpu, @memory, @music, @volume]

    @mutex = Mutex.new
  end

  def update!
    @mutex.synchronize do
      align :left do
        draw @music
      end

      align :center do
        draw @clock
      end

      align :right do
        draw @cpu
        draw @memory
        draw @volume
      end

      draw "\n"
    end
  end

  def draw(s)
    @bar.write "#{s}"
  end

  def align(where)
    draw "%{#{where[0]}}"
    yield
  end

  def run
    @widgets.each do |widget|
      Thread.new { widget.monitor { update! } }
    end

    Thread.new { @bar.each_line { |n| system n } }
    sleep
  end
end
