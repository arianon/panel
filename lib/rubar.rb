Thread.abort_on_exception = true

require_relative 'config'
require_relative 'mkbar'
require_relative 'utils'

require_relative 'monitors/mpd'
require_relative 'monitors/pulseaudio'
require_relative 'monitors/bandwidth'
require_relative 'monitors/memory'
require_relative 'monitors/cpu'

class Rubar
  def initialize
    opts = CONFIG[:lemonbar]

    command = '| lemonbar ' \
              "-F '#{opts.fetch(:foreground, Color.foreground)}' " \
              "-B '#{opts.fetch(:background, Color.background)}' " <<
              opts[:fonts].map { |f| "-f #{f}" }.join(' ')

    @bar = open command, 'w+'

    @pulse = PulseAudio.new
    @mpc = MPC.new
    @mkbar = Mkbar.new(CONFIG[:mkbar])

    @mutex = Mutex.new

    @cpu_current_percentage = 0
    @mem_current_percentage = 0
  end

  # Helpers
  def draw(stuff)
    @bar.write stuff
  end

  def space(n = 1)
    draw ' ' * n
  end

  def align(where)
    draw "%{#{where[0]}}"
    yield
  end

  def respond_to(buttons)
    buttons.each_pair { |btn, cmd| draw "%{A#{btn}:#{cmd}:}" }
    yield
    draw '%{A}' * buttons.length
  end

  # Widget
  def draw_widget(opts = {})
    icon       = opts.fetch :icon, ' WIDGET '
    background = opts.fetch :background, Color.blue
    foreground = opts.fetch :foreground, Color.background
    text       = opts.fetch :text, '<PLACEHOLDER>'

    draw "#{Util.wrap icon, foreground, background} #{text} "
  end

  def time_widget
    opts = {
      icon: Icon.clock,
      background: Color.magenta,
      text: Time.now.strftime('%I:%M:%S %p')
    }

    draw_widget(opts)
  end

  def date_widget
    opts = {
      icon: Icon.date,
      background: Color.red,
      text: Time.now.strftime('%A, %d/%m')
    }

    draw_widget(opts)
  end

  def cpu_widget
    opts = {
      icon: Icon.cpu,
      background: Color.yellow,
      text: @mkbar[@cpu_current_percentage,
                   Util.color_by_percentage(@cpu_current_percentage)]
    }

    draw_widget(opts)
  end

  def mem_widget
    opts = {
      icon: Icon.memory,
      background: Color.cyan,
      text: @mkbar[@mem_current_percentage,
                   Util.color_by_percentage(@mem_current_percentage)]
    }

    draw_widget(opts)
  end

  def music_widget
    return if @mpc.stopped?

    opts = {
      icon: @mpc.playing? ? Icon.music : Icon.paused,
      background: @mpc.playing? ? Color.blue : Color.red,
      text: @mpc.song
    }

    respond_to(1 => 'mpc -q toggle',
               4 => 'mpc -q prev',
               5 => 'mpc -q next') { draw_widget(opts) }
  end

  def volume_widget
    opts = {
      icon: @pulse.muted? ? Icon.muted : Icon.volume,
      background: @pulse.muted? ? Color.red : Color.green,
      text: @mkbar[@pulse.volume]
    }

    respond_to(1 => 'pactl set-sink-mute 0 toggle',
               4 => 'pactl set-sink-volume 0 +5%',
               5 => 'pactl set-sink-volume 0 -5%') { draw_widget(opts) }
  end

  def update!
    @mutex.synchronize do
      align :left do
        date_widget
        time_widget
      end

      align :center do
        music_widget
      end

      align :right do
        cpu_widget
        mem_widget
        volume_widget
      end

      draw "\n"
    end
  end

  def run
    Memory.monitor(3) do |m|
      @mem_current_percentage = m.percentage
      update!
    end

    Cpu.monitor(1) do |perc|
      @cpu_current_percentage = perc
      update!
    end

    @pulse.monitor { update! }
    @mpc.monitor { update! }

    Thread.new do
      @bar.each_line { |n| system n }
    end
  end
end
