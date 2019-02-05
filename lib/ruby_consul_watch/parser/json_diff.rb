# frozen_string_literal: true

require 'hashdiff'
require 'json'
require 'logger'

module RubyConsulWatch
  module Parser
    class JsonDiff
      def initialize(parser_config)
      end

      def parse(previous_watch_json, current_watch_json)
        # JSON.generate(HashDiff.diff(json_to_hash(previous_watch_json), json_to_hash(current_watch_json), array_path: true))
        JSON.pretty_generate(HashDiff.diff(json_to_hash(previous_watch_json), json_to_hash(current_watch_json), array_path: true))
      end

      private

      def json_to_hash(json)
        json = '{}' if json.nil? || json == "null\n"
        JSON.parse(json).map do |kv|
          { kv['Key'] => kv.reject { |key, _value| key == 'Key' } }
        end.reduce({}, :merge)
      end
    end
  end
end
