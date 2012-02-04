# -*- encoding: utf-8 -*-
File.expand_path("../lib", __FILE__).tap { |p| $:.push(p) unless $:.member?(p) }

require "collective/version"

Gem::Specification.new do |s|
  s.name        = "collective"
  s.version     = Hive::VERSION
  s.authors     = ["Mark Lanett"]
  s.email       = ["mark.lanett@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Manage a collection of worker processes}
  
  s.rubyforge_project = "collective"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "redis"
  s.add_dependency "redis-namespace"
end
