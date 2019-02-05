# frozen_string_literal: true

require 'open3'

module ConsulWatcher
  module Destination
    # Send diff output to jq command line
    class Jq
      def initialize(destination_config)
      end

      def send(data)
        Open3.popen3("/usr/bin/env jq '.'") do |stdin, stdout, stderr, wait_thr|
          stdin.puts "#{data}\r\n"
          stdin.close
          error = stderr.read
          stderr.close
          puts stdout.read
          stdout.close
          puts error unless wait_thr.value.success?
          puts
        end
      end
    end
  end
end
