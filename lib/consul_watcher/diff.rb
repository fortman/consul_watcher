# frozen_string_literal: true

require 'hashdiff'

module ConsulWatcher
  class Diff
    def initialize(parser_config) end

    def parse(previous_watch_data, current_watch_data)
      diff = HashDiff.diff(sanitize_data(previous_watch_data), sanitize_data(current_watch_data), array_path: true)
      diff.each do |change|
        change[1] = change[1]&.join('/')
      end
      diff
    end

    private

    def sanitize_data(data)
      data = '[]' if data.nil? || data == "null\n"
      data
    end
  end
end
