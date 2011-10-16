# -*- encoding: utf-8 -*-
File.expand_path("../lib", __FILE__).tap { |p| $:.push(p) unless $:.member?(p) }

require "hive/version"

Gem::Specification.new do |s|
  s.name        = "hive"
  s.version     = Hive::VERSION
  s.authors     = ["Mark Lanett"]
  s.email       = ["mark.lanett@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Manage a collection of worker processes}
  
  s.rubyforge_project = "hive"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
