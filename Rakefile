require "rspec/core/rake_task"
require "cucumber/rake/task"
require "bundler/setup"
Bundler.require

desc "Default run spec"
task :default => :spec
desc "Default run cucumber"
task :default => :cucumber


desc "Run spec"
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = "--format documentation"
end

desc "Run cucumber"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "--format pretty"
end
