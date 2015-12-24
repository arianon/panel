require_relative '../config'

class Clock
  C = CONFIG.clock

  def initialize
    @icon = "%{F#{C.color}}%{R} #{C.icon} %{R}%{F-} "
  end

  def monitor
    loop do
      yield
      sleep C.reload
    end
  end

  def to_s
    @icon + Time.now.strftime(C.format)
  end
end

if __FILE__ == $PROGRAM_NAME
  clock = Clock.new
  clock.monitor { puts clock }
end
