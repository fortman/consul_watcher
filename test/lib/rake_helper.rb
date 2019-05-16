#!/usr/bin/env ruby

# frozen_string_literal: true

require 'open3'
require 'net/http'
require 'bunny'
require 'json'

module ConsulWatcher
  module RakeHelper
    def self.config_rabbitmq
      conn = Bunny.new(host: 'localhost', port: '5672', vhost: '/', \
                       username: 'guest', password: 'guest')
      conn.start
      ch = conn.create_channel
      ex = Bunny::Exchange.new(ch, :topic, 'amq.topic', durable: true)
      @queue = ch.queue('consul_watcher', durable: true).bind(ex, routing_key: 'consul_watcher.key.#')
      nil
    end

    def self.process_message(delivery_info, properties, body)
      puts "routing_key: #{delivery_info[:routing_key]}"
      puts "consumer_tag: #{delivery_info[:consumer_tag]}"
      puts "delivery_tag version: #{delivery_info[:delivery_tag].version}"
      puts "delivery_tag tag: #{delivery_info[:delivery_tag].tag}"
      puts "routing_key: #{delivery_info[:routing_key]}"
      puts "channel: #{delivery_info[:channel]}"
      puts "properties: #{JSON.pretty_generate(properties)}"
      puts "body:\n#{body}"
      puts
    end

    def self.consumer_start
      @consumer ||= @queue.subscribe(block: true, &itself.method(:process_message))
      nil
    end

    def self.consumer_stop
      @consumer&.cancel
      @consumer = nil
    end
  end
end
