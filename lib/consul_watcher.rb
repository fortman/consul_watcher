#!/usr/bin/env ruby

# frozen_string_literal: true

require 'json'
require 'hashdiff'
require 'consul_watcher/filters'

# Top Level module to run watch logic
module ConsulWatcher
  def self.watch(config)
    #Encoding.default_external = Encoding::UTF_8
    #Encoding.default_external = Encoding::ASCII_8BIT
    assemble(config)
    current_watch_json = $stdin.read
    previous_watch_json = @storage.fetch
    changes = @watch_type.get_changes(previous_watch_json, current_watch_json)
    # @watch_type.filters.print_filters
    changes.each do |change|
      @destination.send(change)
    end
    @storage.push(current_watch_json) unless changes.empty?
  end

  private

  def self.assemble(config)
    @storage = get_storage(config['storage'])
    @watch_type = get_watch_type(config['watch_type'])
    @destination = get_destination(config['destination'])
    
    @watch_type.filters = ConsulWatcher::Filters.new(config['watch_type'] || {})
    @watch_type.filters.add_filters(@storage.get_filters)
  end

  def self.get_storage(storage_config)
    classname = storage_config['classname']
    require classname_to_file(classname)
    Object.const_get(classname).new(storage_config)
  end

  def self.get_watch_type(watch_type_config)
    classname = watch_type_config['classname']
    require classname_to_file(classname)
    Object.const_get(classname).new(watch_type_config)
  end

  def self.get_destination(destination_config)
    classname = destination_config['classname']
    require classname_to_file(classname)
    Object.const_get(classname).new(destination_config)
  end

  # Dynamically require handler class from passed in handler class
  def self.classname_to_file(classname)
    classname.gsub('::', '/').gsub(/([a-zA-Z])([A-Z])/, '\1_\2').downcase
  end
end
