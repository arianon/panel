#!/usr/bin/ruby -wU
# coding: utf-8

require_relative '../../config'

module Mkbar
  extend self

  C = CONFIG.mkbar
  S = CONFIG.colors

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
      S.red
    elsif value >= 50
      S.yellow
    elsif value >= 25
      S.cyan
    else
      S.green
    end
  end

  def [](value, color = false)
    value = wrap(value)
    bar = ''
    my_foreground = color ? color_by_perc(value) : C.foreground

    value = (value / 100.0 * C.size).round
    remainder = C.size - value

    bar << "%{F#{my_foreground}}"
    bar << C.char1 * value
    bar << "%{F#{C.background}}"
    bar << C.char2 * remainder
    bar << '%{F-}'
  end
end
