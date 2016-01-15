#!/usr/bin/ruby -wU
# coding: utf-8

require_relative '../../config'
require_relative '../../xresources'

module Mkbar
  extend self

  C = CONFIG.mkbar

  # Forgive calculation errors.
  def wrap(value)
    if value > 100
      100
    elsif value <= 0
      0
    else
      value
    end
  end

  def color_by_perc(value)
    if value >= 75
      Xresources['red']
    elsif value >= 50
      Xresources['yellow']
    elsif value >= 25
      Xresources['cyan']
    else
      Xresources['green']
    end
  end

  def [](value, color = false)
    value = wrap(value)
    bar = ''
    my_foreground = color ? color_by_perc(value) : Xresources[C.foreground]

    value = (value / 100.0 * C.size).round
    remainder = C.size - value

    bar << "%{F#{my_foreground}}"
    bar << C.char1 * value
    bar << "%{F#{Xresources[C.background]}}"
    bar << C.char2 * remainder
    bar << '%{F-}'
  end
end
