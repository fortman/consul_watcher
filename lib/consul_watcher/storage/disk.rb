# frozen_string_literal: true

require 'fileutils'
require 'zlib'
require 'flazm_ruby_helpers/class'

module ConsulWatcher
  module Storage
    # Disk storage for previous watch data
    class Disk
      include FlazmRubyHelpers::Class

      def initialize(storage_config)
        initialize_variables(storage_config)
        FileUtils.mkdir_p(@cache_dir) unless File.directory?(@cache_dir)
      end

      def fetch
        file = File.open(cache_file_name, mode: 'r')
        data = file.read
        file.close
        data = Zlib::Inflate.inflate(data) if @compress
        data
      rescue Errno::ENOENT
        '{}'
      end

      def push(data)
        file = File.open(cache_file_name, mode: 'w')
        file.write(@compress ? Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION) : data)
        file.close
      end

      def get_filters
        nil
      end

      private

      def cache_file_name
        "#{@cache_dir}/#{@storage_name}.json"
      end

      def defaults
        logger = Logger.new(STDOUT)
        logger.level = Logger::WARN
        {
          logger: logger,
          storage_name: 'disk',
          cache_dir: 'watch/json-store',
          consul_http_addr: 'http://localhost:8500',
          consul_token: nil,
          compress: false
        }
      end
    end
  end
end
