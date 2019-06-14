# frozen_string_literal: true

require 'base64'
require 'flazm_ruby_helpers/class'
require 'diplomat'

module ConsulWatcher
  module WatchType
    class Key
      include FlazmRubyHelpers::Class

      attr_accessor :filters
      def initialize(watch_config)
        initialize_variables(watch_config)
      end

      def get_changes(previous_watch_json, current_watch_json, dc)
        json_diff = get_diff(previous_watch_json, current_watch_json)

        changes = json_diff.each.collect do |change|
          formatted_change = format_change('key', change, dc)
          decode(formatted_change) if @decode_values
          formatted_change
        end.compact
        changes = changes.each.collect.reject {|change| @filters.filter?(change)}
        changes
      end

      def filters=(f)
        @filters = f
      end

      private
      def get_diff(previous_watch_json, current_watch_json)
         HashDiff.diff(json_to_hash(previous_watch_json),
                                  json_to_hash(current_watch_json),
                                  array_path: true)
      end

      def decode(change)
        return unless change['key_property'] == 'Value'

        change['old_value'] = Base64.decode64(change['old_value']) if change['old_value'].is_a? String
        change['new_value'] = Base64.decode64(change['new_value']) if change['new_value'].is_a? String
        change['new_value']['Value'] = Base64.decode64(change['new_value']['Value']) if change['change_type'] == '+' && change['new_value']['Value'].is_a?(String)
        change['old_value']['Value'] = Base64.decode64(change['old_value']['Value']) if change['change_type'] == '-' && change['old_value']['Value'].is_a?(String)
      end

      def json_to_hash(json)
        json = '{}' if json.nil? || json == "null\n"
        JSON.parse(json).map do |kv|
          { kv['Key'] => kv.reject { |key, _value| key == 'Key' } }
        end.reduce({}, :merge)
      end

      def format_change(watch_type, change, dc)
        old_value, new_value = change_values(change)
        {
          'id' => "consul_watcher.key.#{change[1][0].tr('/', '.')}",
          'consul_dc' => dc,
          'watch_type' => watch_type,
          'key_path' =>  change[1][0],
          'key_property' => change[1][1],
          'old_value' => old_value,
          'new_value' => new_value
        }
      end

      def routing_key(change)
      end

      def change_values(change)
        # Return old_value, new_value
        return nil, change[2] if change[0] == '+'
        return change[2], nil if change[0] == '-'
        return change[2], change[3] if change[0] == '~'
      end

      def defaults
        {
          watch_type: 'key',
          decode_values: true
        }
      end
    end
  end
end
