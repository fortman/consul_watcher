# frozen_string_literal: true

require 'bunny'
require 'consul_watcher/class_helper'
require 'json'

module ConsulWatcher
  module Destination
    # Send diff output to jq command line
    class Amqp
      include ClassHelper

      def initialize(destination_config)
        populate_variables(destination_config)
        setup_rabbitmq
      end

      def setup_rabbitmq
        @conn = Bunny.new(host: @rabbitmq_server,
                          port: @rabbitmq_port,
                          vhost: @rabbitmq_vhost,
                          username: @rabbitmq_username,
                          password: @rabbitmq_password)
        @conn.start
        @ch = @conn.create_channel
        @ex = Bunny::Exchange.new(@ch,
                                  :topic,
                                  @rabbitmq_exchange,
                                  durable: true)
      end

      def send(change)
        @logger.debug('publishing message')
        routing_key = change['id']
        @logger.debug("routing_key: #{routing_key}")
        begin
          @ex.publish(JSON.pretty_generate(change), routing_key: change['id'])
        rescue Encoding::UndefinedConversionError
          change['forced_utf8'] = true
          data = change.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
          @ex.publish(JSON.pretty_generate(data), routing_key: change['id'])
        end
      end

      def defaults
        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG
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
end
