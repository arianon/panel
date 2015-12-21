#!/usr/bin/ruby -wU
# coding: utf-8

require_relative 'config'
require_relative 'utils'

class Mkbar
  def initialize(char1: '━',
                 char2: '━',
                 foreground: Color.foreground,
                 background: Color.black,
                 size: 20)

    @char1      = char1
    @char2      = char2
    @foreground = foreground
    @background = background
    @size       = size
  end

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

  def [](value, foreground = nil)
    value = wrap(value)
    bar = ''

    value = (value / 100.0 * @size).round
    remainder = @size - value

    bar << Util.foreground(foreground || @foreground)
    bar << @char1 * value
    bar << Util.foreground(@background)
    bar << @char2 * remainder
    bar << Util.foreground

    bar
  end
end
