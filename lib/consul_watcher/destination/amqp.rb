# frozen_string_literal: true

require 'bunny'

module ConsulWatcher
  module Destination
    # Send diff output to jq command line
    class Amqp
      def initialize(destination_config)
        @conn = Bunny.new(host: destination_config['rabbitmq']['server'] || 'localhost',
                          port: destination_config['rabbitmq']['port'] || '5672',
                          vhost: destination_config['rabbitmq']['vhost'] || '/',
                          username: destination_config['rabbitmq']['username'] || 'guest',
                          password: destination_config['rabbitmq']['password'] || 'guest')
        @conn.start
        @ch = @conn.create_channel
        @ex = Bunny::Exchange.new(@ch,
                                  :topic,
                                  destination_config['rabbitmq']['exchange'] || 'amq.topic',
                                  durable: true)
      end

      def send(change, routing_key)
        puts 'publishing message'
        @ex.publish(change, routing_key: "consul_watcher.#{routing_key}")
      end
    end
  end
end
