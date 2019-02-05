#!/usr/bin/env ruby

# frozen_string_literal: true

# Top Level module to run watch logic
module RubyConsulWatch
  def self.watch(watch_name, config)
    storage = get_storage(config['storage'])
    parser = get_parser(config['parser'])
    destination = get_destination(config['data_destination'])

    current_watch_json = $stdin.read
    previous_watch_json = storage.fetch(watch_name)

    json_data = parser.parse(previous_watch_json, current_watch_json)
    destination.send(json_data)

    storage.push(watch_name, current_watch_json)
  end

  def self.get_storage(storage_config)
    classname = storage_config['class]'] || 'RubyConsulWatch::Storage::Disk'
    require classname_to_file(classname)
    Object.const_get(classname).new(storage_config)
  end

  def self.get_parser(parser_config)
    classname = parser_config['class'] || 'RubyConsulWatch::Parser::JsonDiff'
    require classname_to_file(classname)
    Object.const_get(classname).new(parser_config)
  end

  def self.get_destination(destination_config)
    classname = destination_config['classname'] || 'RubyConsulWatch::DataDestination::Jq'
    require classname_to_file(classname)
    Object.const_get(classname).new(destination_config)
  end

  # Dynamically require handler class from passed in handler class
  def self.classname_to_file(classname)
    classname.gsub('::', '/').gsub(/([a-zA-Z])([A-Z])/, '\1_\2').downcase
  end
end
