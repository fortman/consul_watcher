#!/usr/bin/env ruby

# frozen_string_literal: true

require 'json'
require 'hashdiff'

# Top Level module to run watch logic
module ConsulWatcher
  def self.watch(watch_type, storage_name, config)
    storage = get_storage(config['storage']) if config['storage']
    watch_type = get_watch_type(config['watch_type']) if config['watch_type']
    filters = get_filters(config['filters']) if config['filters']
    destination = get_destination(config['destination']) if config['destination']

    current_watch_json = $stdin.read
    previous_watch_json = storage.fetch(storage_name)
    changes = watch_type.get_changes(previous_watch_json, current_watch_json)
    changes.each do |change|
      destination.send(JSON.pretty_generate(change), watch_type.amqp_routing_key(change))
    end
    storage.push(storage_name, current_watch_json)
  end

  def self.get_storage(storage_config)
    classname = storage_config['classname'] || 'ConsulWatcher::Storage::Disk'
    require classname_to_file(classname)
    Object.const_get(classname).new(storage_config)
  end

  def self.get_watch_type(watch_type_config)
    classname = watch_type_config['classname'] || 'ConsulWatcher::WatchType::Checks'
    require classname_to_file(classname)
    Object.const_get(classname).new(watch_type_config)
  end

  def self.get_destination(destination_config)
    classname = destination_config['classname'] || 'ConsulWatcher::Destination::Jq'
    require classname_to_file(classname)
    Object.const_get(classname).new(destination_config)
  end

  # Dynamically require handler class from passed in handler class
  def self.classname_to_file(classname)
    classname.gsub('::', '/').gsub(/([a-zA-Z])([A-Z])/, '\1_\2').downcase
  end
end
