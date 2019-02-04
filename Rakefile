# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'open3'

spec_file = Gem::Specification.load('ruby_consul_watch.gemspec')

task default: :docker

task :docker_tag, [:version, :docker_image_id] do |_task, args|
  puts "#{args['docker_image_id']} => #{args['version']}"
  tag_cmd = "docker tag #{args['docker_image_id']} ruby_consul_watch:#{args['version']}"
  Open3.popen3(tag_cmd) do |_stdin, _stdout, stderr, wait_thr|
    error = stderr.read
    puts error unless wait_thr.value.success?
  end
end

task docker: [:build] do
  build_cmd = "docker build --build-arg gem_file=ruby_consul_watch-#{spec_file.version}.gem ."
  Open3.popen3(build_cmd) do |_stdin, stdout, stderr, wait_thr|
    output = stdout.read
    error = stderr.read
    if wait_thr.value.success?
      docker_image_id = output.match(/Successfully built (.*)$/i).captures[0]
      puts "#{output}\n"
      Rake::Task['docker_tag'].invoke(spec_file.version, docker_image_id)
      Rake::Task['docker_tag'].reenable
      Rake::Task['docker_tag'].invoke('latest', docker_image_id)
    else
      puts error
    end
  end
end
