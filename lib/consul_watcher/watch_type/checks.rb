# frozen_string_literal: true

require 'open3'

module ConsulWatcher
  module WatchType
    class Checks
      def initialize(destination_config) end

      def get_changes(previous_watch_json, current_watch_json)
        HashDiff.diff(json_to_hash(previous_watch_json),
                      json_to_hash(current_watch_json),
                      array_path: true)
      end

      def id(change)
        "key.#{change[1][0].tr('/', '.')}"
      end

      def json_to_hash(json)
        json = '{}' if json.nil? || json == "null\n"
        JSON.parse(json).map do |check|
          { check['Node'] => { check['CheckID'] => check } }
        end.reduce({}, :merge)
      end
    end
  end
end
