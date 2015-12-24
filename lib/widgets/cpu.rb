require_relative '../config'

class CPU
  C = CONFIG.cpu

  def initialize
    @perc = 0.0
    @icon = "%{F#{C.color}}%{R} #{C.icon} %{R}%{F-}"
    update!
  end

  def to_s
    "#{@icon} #{@perc.round}%"
  end

  def monitor
    loop do
      yield
      prev_used = @used
      prev_total = @total
      sleep C.rate
      update!
      @perc = (prev_used - @used) * 100 / (prev_total - @total)
    end
  end

  def update!
    tmp = open('/proc/stat', &:gets).split[1..-1].map!(&:to_f)
    @used = tmp[0] + tmp[2] # used = user+system
    @total = @used + tmp[3]  # total = used+idle
  end
end
