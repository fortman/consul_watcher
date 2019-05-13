# frozen_string_literal: true

require 'open3'
require 'logger'

module ConsulWatcher
  module Destination
    # Send diff output to jq command line
    class Jq
      def initialize(destination_config)
        populate_variables(destination_config)
      end

      def send(change)
        change_json = JSON.pretty_generate(change)
        Open3.popen3("/usr/bin/env jq '.'") do |stdin, stdout, stderr, wait_thr|
          { out: stdout, err: stderr }.each do |_key, stream|
            threads << Thread.new do
              until (raw_line = stream.gets).nil?
                output << raw_line.to_s
                @logger.info(raw_line.to_s) if stream
              end
            end
          end
          threads.each(&:join)
          status = wait_thr.value.success?
        end
      end

      def defaults
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO
        {
          logger: logger,
          rabbitmq_server: 'localhost',
          rabbitmq_port: '5672',
          rabbitmq_vhost: '/',
          rabbitmq_username: 'guest',
          rabbitmq_password: 'guest',
          rabbitmq_exchange: 'amq.topic'
        }
    end
  end
end
