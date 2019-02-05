# frozen_string_literal: true

# This will be a module to store previous consul watch json to compare with previous watch data
module ConsulWatcher
  module Storage
    # Consul storage for previous watch data
    class Disk
      def initialize(storage_config)
        @parent_dir = storage_config['storage_parent_dir'] || '/tmp'
      end
    end
  end
end