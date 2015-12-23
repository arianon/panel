require 'yaml'
require 'recursive-open-struct'

CONFIG = RecursiveOpenStruct.new(YAML.load_file(File.expand_path('../../config.yml', __FILE__)))
