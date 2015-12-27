require_relative '../../config'

module Iconify
  extend self

  def foreground(icon, color)
    "%{F#{color}} #{icon} %{F-}"
  end

  def background(icon, color)
    "%{F#{color}}%{R} #{icon} %{R}%{F-} "
  end

  def [](icon, color)
    if CONFIG.reversed_icons
      background(icon, color)
    else
      foreground(icon, color)
    end
  end
end
