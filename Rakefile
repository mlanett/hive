require "bundler/gem_tasks"
require 'rspec/core/rake_task'

# the minitest way
# task :test do
#   require_relative "./spec/helper"
#   FileList["spec/**/*_{spec}.rb"].each { |f| load(f) }
# end

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
