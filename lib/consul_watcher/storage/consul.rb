# frozen_string_literal: true

require 'diplomat'
require 'consul_watcher/class_helper'
require 'zlib'

# This will be a module to store previous consul watch json to compare with previous watch data
module ConsulWatcher
  module Storage
    # Consul storage for previous watch data
    class Consul
      include ClassHelper

      def initialize(storage_config)
        populate_variables(storage_config)
        config_diplomat
      end

      def fetch
        @logger.debug('fetching state from consul')
        data = Diplomat::Kv.get(cache_file_name)
        data = Zlib::Inflate.inflate(data) if @encrypt
        data
      rescue Diplomat::KeyNotFound
        '{}'
      end

      def push(data)
        @logger.debug('pushing state to consul')
        Diplomat::Kv.put(cache_file_name, @encrypt ? Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION) : data)
      end

      def get_filters
        { 'key_path' => cache_file_name }
      end

      private

      def cache_file_name
        "#{@parent_dir}/#{@storage_name}"
      end

      def config_diplomat
        Diplomat.configure do |config|
          # Set up a custom Consul URL
          config.url = @consul_http_addr
          # Set extra Faraday configuration options and custom access token (ACL)
          config.options = {headers: {"X-Consul-Token" => @consul_token}}
        end
      end

      def defaults
        logger = Logger.new(STDOUT)
        logger.level = Logger::WARN
        {
          logger: logger,
          storage_name: 'kv',
          parent_dir: 'watch/json-store',
          consul_http_addr: 'http://localhost:8500',
          consul_token: nil,
          encrypt: false
        }
      end
    end
  end
end
