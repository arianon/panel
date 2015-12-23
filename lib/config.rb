require 'yaml'
require 'json'

CONFIG = JSON.parse(
  YAML.load_file(File.expand_path('../../config.yml', __FILE__)).to_json,
  object_class: OpenStruct)
