# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'open3'
require 'flazm_ruby_helpers/os'
require 'flazm_ruby_helpers/project'
require 'flazm_ruby_helpers/http'
require_relative 'test/lib/rake_helper'

spec_file = Gem::Specification.load('consul_watcher.gemspec')

task default: :docker_build

task docker_build: [:build] do
  build_cmd = "docker build --build-arg gem_file=consul_watcher-#{spec_file.version}.gem ."
  image_id = FlazmRubyHelpers::Project::Docker.build(build_cmd)
  FlazmRubyHelpers::Project::Docker.tag(spec_file.metadata['docker_image_name'],
                                        spec_file.version,
                                        image_id)
  FlazmRubyHelpers::Project::Docker.tag(spec_file.metadata['docker_image_name'],
                                        'latest',
                                        image_id)
end

task :start_deps do
  cmd = 'docker-compose --file test/docker-compose.yml up -d consul rabbitmq'
  FlazmRubyHelpers::Os.exec(cmd)
  urls = [
    'http://localhost:8500/v1/status/leader',
    'http://localhost:15672'
  ]
  FlazmRubyHelpers::Http.wait_for_urls(urls)
end

task up: [:start_deps] do
  _output, _success = FlazmRubyHelpers::Os.exec('docker-compose --file test/docker-compose.yml up -d consul-watcher')
end

task :consume do
  ConsulWatcher::RakeHelper.config_rabbitmq
  puts 'Starting queue consumer'
  ConsulWatcher::RakeHelper.consumer_start
end

task :down do
  _output, _success = FlazmRubyHelpers::Os.exec('docker-compose --file test/docker-compose.yml down')
end

task publish: [:build, :docker_build] do
  FlazmRubyHelpers::Project::Git.publish(spec_file.version.to_s, 'origin', 'master')
  FlazmRubyHelpers::Project::Docker.publish(spec_file.metadata['docker_image_name'], spec_file.version.to_s)
  FlazmRubyHelpers::Project::Docker.publish(spec_file.metadata['docker_image_name'], 'latest')
  FlazmRubyHelpers::Project::Gem.publish(spec_file.name.to_s, spec_file.version.to_s)
end

task :unpublish do
  _output, _success = FlazmRubyHelpers::Os.exec("git tag --delete #{spec_file.version.to_s}")
  _output, _success = FlazmRubyHelpers::Os.exec("gem yank #{spec_file.name.to_s} -v #{spec_file.version.to_s}")
  puts "Please delete the tag from dockerhub at https://cloud.docker.com/repository/registry-1.docker.io/#{spec_file.metadata['docker_image_name']}/tags"
end
