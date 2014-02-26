#!/usr/bin/env rake
require 'rspec/core/rake_task'

task :default => :all

desc "Run the spec tasks"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--tag ~integration"]
end

desc "Run the integration tests"
RSpec::Core::RakeTask.new(:integration) do |t|
  t.rspec_opts = ["--tag integration"]
end
  
RSpec::Core::RakeTask.new(:all)
