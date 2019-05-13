# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'open3'
require_relative 'lib/consul_watcher/rake_helper'

spec_file = Gem::Specification.load('consul_watcher.gemspec')

task default: :docker_build

task :docker_tag, [:version, :docker_image_id] do |_task, args|
  puts "Docker id #{args['docker_image_id']} => tag rfortman/consul_watcher:#{args['version']}"
  tag_cmd = "docker tag #{args['docker_image_id']} rfortman/consul_watcher:#{args['version']}"
  Open3.popen3(tag_cmd) do |_stdin, _stdout, stderr, wait_thr|
    error = stderr.read
    puts error unless wait_thr.value.success?
  end
end

task docker_build: [:build] do
  docker_image_id = nil
  build_cmd = "docker build --build-arg gem_file=consul_watcher-#{spec_file.version}.gem ."
  threads = []
  Open3.popen3(build_cmd) do |_stdin, stdout, stderr, wait_thr|
    { out: stdout, err: stderr }.each do |key, stream|
      threads << Thread.new do
        until (raw_line = stream.gets).nil?
          match = raw_line.match(/Successfully built (.*)$/i)
          docker_image_id = match.captures[0] if match
          puts raw_line.to_s
        end
      end
    end
    threads.each(&:join)
    if wait_thr.value.success?
      Rake::Task['docker_tag'].invoke(spec_file.version, docker_image_id)
      Rake::Task['docker_tag'].reenable
      Rake::Task['docker_tag'].invoke('latest', docker_image_id)
    end
  end
end

task :start_deps do
  cmd = 'docker-compose --file test/docker-compose.yml up -d consul rabbitmq'
  ConsulWatcher::RakeHelper.exec(cmd)
  urls = [
    'http://localhost:8500/v1/status/leader',
    'http://localhost:15672'
  ]
  ConsulWatcher::RakeHelper.wait_for_urls(urls)
  ConsulWatcher::RakeHelper.config_rabbitmq
end

task up: [:start_deps] do
  cmd = 'docker-compose --file test/docker-compose.yml up -d consul-watcher'
  _output, _status = ConsulWatcher::RakeHelper.exec(cmd)
  puts 'Starting queue consumer'
  ConsulWatcher::RakeHelper.consumer_start
end

task :down do
  cmd = 'docker-compose --file test/docker-compose.yml down'
  _output, _status = ConsulWatcher::RakeHelper.exec(cmd)
end
