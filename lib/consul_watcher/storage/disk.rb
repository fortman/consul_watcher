# frozen_string_literal: true

module ConsulWatcher
  module Storage
    # Disk storage for previous watch data
    class Disk
      def initialize(storage_config)
        @parent_dir = storage_config['storage_parent_dir'] || '/tmp'
      end

      def fetch(watch_name)
        file = File.open(cache_file_name(watch_name), mode: 'r')
        data = file.read
        file.close
        data
      rescue Errno::ENOENT
        '{}'
      end

      def push(watch_name, data)
        file = File.open(cache_file_name(watch_name), mode: 'w')
        file.write(data)
        file.close
      end

      private

      def cache_file_name(watch_name)
        "#{@parent_dir}/#{watch_name}.json"
      end
    end
  end
end
