require "bundler/gem_tasks"

task :test do
  require_relative "./test/helper"
  FileList["{spec,test}/**/*_{spec,test}.rb"].each { |f| load(f) }
end

task :default => :test
