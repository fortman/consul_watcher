# frozen_string_literal: true

require 'consul_watcher/class_helper'

module ConsulWatcher
  class Filters
    include ClassHelper

    def initialize(filter_config)
      populate_variables(filter_config)
    end

    def add_filters(filters_to_add)
      @filters.merge!(filters_to_add)
    end

    def filter?(change)
      @filters.each do |attribute, regex|
        match = change.key?(attribute) ? change[attribute].match?(/#{regex}/) : false
        if match
          @logger.debug("filtered #{change['id']} #{attribute} on regex #{regex}")
          return true 
        end
      end
      false
    end

    def print_filters
      @filters.each do |filter|
        @logger.debug("filter: #{filter}")
      end
    end

    private

    def defaults
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      {
        logger: logger,
        filters: {}
      }
    end
  end
end