require 'yaml'

CONFIG = YAML.load_file(File.expand_path '../../config.yml', __FILE__).freeze

module Color
  CONFIG[:colors].each_pair do |name, color|
    define_singleton_method(name) { format('#FF%06X', color) }
  end
end

module Icon
  CONFIG[:icons].each_pair do |name, icon|
    define_singleton_method(name) { " #{icon} " }
  end
end
