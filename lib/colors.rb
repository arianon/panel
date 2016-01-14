module Xresource
  ALIASES = {
    black:   { dark: :color0, bright: :color8 },
    red:     { dark: :color1, bright: :color9 },
    green:   { dark: :color2, bright: :color10 },
    yellow:  { dark: :color3, bright: :color11 },
    blue:    { dark: :color4, bright: :color12 },
    magenta: { dark: :color5, bright: :color13 },
    cyan:    { dark: :color6, bright: :color14 },
    white:   { dark: :color7, bright: :color15 }
  }

  @db = File.readlines(ENV['HOME'] + '/.Xresources')
        .select { |line| line =~ /(back|fore)ground|color[0-9]+:/ }
        .map do |line|
          *_, name, color = line.split(/[.*:]/)
          [name.to_sym, color.strip]
        end.to_h

  @db.each do |name, value|
    define_singleton_method(name) { value }
  end

  ALIASES.each do |name, tones|
    # XXX: Use bright values by default
    define_singleton_method(name) { send(tones[:bright]) }

    tones.each do |tone, color|
      define_singleton_method(:"#{tone}#{name}") { send(color) }
    end
  end
end
