# frozen_string_literal: true

require 'bunny'
require 'json'
require 'flazm_ruby_helpers/class'

module ConsulWatcher
  module Destination
    # Send diff output to jq command line
    class Amqp
      include FlazmRubyHelpers::Class

      def initialize(destination_config)
        initialize_variables(destination_config)
        setup_rabbitmq
      end

      def setup_rabbitmq
        @conn = Bunny.new(rabbitmq_opts)
        @conn.start
        @ch = @conn.create_channel
        @ex = Bunny::Exchange.new(@ch,
                                  :topic,
                                  @rabbitmq_exchange,
                                  durable: true)
      end

      def rabbitmq_opts
        opts = {}
        opts[:vhost] = @rabbitmq_vhost
        opts[:username] = @rabbitmq_username
        opts[:password] = @rabbitmq_password
        if @rabbitmq_addresses
          opts[:addresses] = @rabbitmq_addresses
        elsif @rabbitmq_hosts
          opts[:hosts] = @rabbitmq_hosts
          opts[:port] = @rabbitmq_port if @rabbitmq_port
        elsif @rabbitmq_host
          opts[:host] = @rabbitmq_host
          opts[:port] = @rabbitmq_port if @rabbitmq_port
        end
        opts
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
          rabbitmq_host: nil,
          rabbitmq_hosts: nil,
          rabbitmq_addresses: nil,
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
