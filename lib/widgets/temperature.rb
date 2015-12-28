# coding: utf-8
require_relative '../config'
require_relative 'helpers/iconify'
require_relative 'helpers/mkbar'

class Temperature
  C = CONFIG.temperature

  def initialize
    @maxtemp = maxtemp
    @icon = Iconify[C.icon, C.color]
  end

  def to_s
    widget = ''
    widget << @icon

    widget <<
      case C.type
      when /.*bar/
        Mkbar[curtemp, C.type == 'colored_bar']
      when 'percentage'
        format('%.1f%%', perctemp)
      when 'degrees'
        format('%.1f°C', curtemp)
      end
  end

  def curtemp
    File.read('/sys/class/hwmon/hwmon0/temp1_input').to_f / 1000
  end

  def maxtemp
    File.read('/sys/class/hwmon/hwmon0/temp1_max').to_f / 1000
  end

  def perctemp
    curtemp / @maxtemp * 100
  end

  def monitor
    loop do
      yield
      sleep C.reload
    end
  end
end
