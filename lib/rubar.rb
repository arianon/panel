Thread.abort_on_exception = true

require_relative 'config'
require_relative 'xresources'

require_relative 'widgets/alsa'
require_relative 'widgets/bandwidth'
require_relative 'widgets/clock'
require_relative 'widgets/cpu'
require_relative 'widgets/memory'
require_relative 'widgets/mpc'
require_relative 'widgets/temperature'
require_relative 'widgets/pulseaudio'

class Rubar
  C = CONFIG.lemonbar
  WIDGETS = {
    alsa: ALSA,
    bandwidth: Bandwidth,
    clock: Clock,
    cpu: CPU,
    memory: Memory,
    music: MPC,
    temperature: Temperature,
    pulseaudio: PulseAudio
  }.freeze

  def initialize
    cmd = ['| lemonbar']
    cmd << "-F '#{Xresources[C.foreground]}' -B '#{Xresources[C.background]}'"
    cmd << "-g #{C.geometry}" if C.geometry
    cmd << C.fonts.map { |f| "-f '#{f}'" }.join(' ')
    cmd << "-a #{C.clickable_areas}"
    cmd << '-d' if C.force_docking
    cmd << '-b' if C.bottom

    @bar = open(cmd.join(' '), 'w+')

    @widgets = selected_widgets(C.format)
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
  rescue Interrupt
    puts 'Exiting gracefully...'
    Process.kill('TERM', @bar.pid)
    exit
  end

  private

  def selected_widgets(s)
    widgets = WIDGETS.dup
    widgets
      .select! { |widget| tokenize(s).include?(widget) }
      .each { |key, object| widgets[key] = object.new }
  end

  def tokenize(s)
    s.split(/[| ]/).map!(&:to_sym)
  end

  def parse(s)
    s.gsub!(/(\w+)/, '%{\1}')
      .sub!('|', '%%{c}')
      .sub!('|', '%%{r}') << " \n"
  end
end
