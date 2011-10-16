require "bundler/gem_tasks"

task :test do
  require_relative "./spec/helper"
  FileList["spec/**/*_{spec}.rb"].each { |f| load(f) }
end

task :default => :test
