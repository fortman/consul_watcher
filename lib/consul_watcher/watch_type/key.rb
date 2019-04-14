# frozen_string_literal: true

require 'base64'

module ConsulWatcher
  module WatchType
    class Key
      def initialize(destination_config) end

      def get_changes(previous_watch_json, current_watch_json)
        json_diff = HashDiff.diff(json_to_hash(previous_watch_json),
                                  json_to_hash(current_watch_json),
                                  array_path: true)
        json_diff.each.collect do |change|
          # change[1] = change[1].join('/')
          change[2] = Base64.decode64(change[2]) if change[2].is_a? String
          change[3] = Base64.decode64(change[3]) if change[3].is_a? String
          { 
            'watch_type' => 'key',
            'id' => id(change),
            'diff' => change
          }
        end
        #json_diff.reject { |change| change[0] == '~' && change[1][-1] == 'ModifyIndex' }
      end

      def id(change)
        "key.#{change[1][0].tr('/', '.')}"
      end

      def json_to_hash(json)
        json = '{}' if json.nil? || json == "null\n"
        JSON.parse(json).map do |kv|
          { kv['Key'] => kv.reject { |key, _value| key == 'Key' } }
        end.reduce({}, :merge)
      end
      
    end
  end
end
