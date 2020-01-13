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
        setup_amqp
      end

      def setup_amqp
        @conn = Bunny.new(amqp_opts)
        @conn.start
        @ch = @conn.create_channel
        @ex = Bunny::Exchange.new(@ch,
                                  :topic,
                                  @amqp_exchange,
                                  durable: true)
      end

      def amqp_opts
        opts = {}
        opts[:vhost] = @amqp_vhost
        opts[:username] = @amqp_username
        opts[:password] = @amqp_password
        if @amqp_addresses
          opts[:addresses] = @amqp_addresses
        elsif @amqp_hosts
          opts[:hosts] = @amqp_hosts
          opts[:port] = @amqp_port if @amqp_port
        elsif @amqp_host
          opts[:host] = @amqp_host
          opts[:port] = @amqp_port if @amqp_port
        end
        opts
      end

      def send(change)
        @logger.debug('publishing message')
        routing_key = change['id'].truncate(255, omission: '.truncated')
        @logger.debug("routing_key: #{routing_key}")
        begin
          @ex.publish(JSON.pretty_generate(change), routing_key: routing_key)
        rescue Encoding::UndefinedConversionError
          change['forced_utf8'] = true
          data = change.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
          @ex.publish(JSON.pretty_generate(data), routing_key: routing_key)
        end
      end

      def defaults
        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG
        {
          logger: logger,
          amqp_host: nil,
          amqp_hosts: nil,
          amqp_addresses: nil,
          amqp_port: '5672',
          amqp_vhost: '/',
          amqp_username: 'guest',
          amqp_password: 'guest',
          amqp_exchange: 'amq.topic'
        }
      end
    end
  end
end
