#require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

PROJECT_ROOT = File.dirname(__FILE__)

desc "Run all specs in the specs/ directory ("
task :rspec do
  Dir['./specs/*_spec.rb'].each do |spec|
    puts `rspec #{spec} --color`
  end
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  #spec.rspec_opts = "--format=nested"
end

task :default => :spec

desc "Run test suite"
task :test do
  Dir['test/**/*_test.rb'].each {|file| require_relative file}
end
