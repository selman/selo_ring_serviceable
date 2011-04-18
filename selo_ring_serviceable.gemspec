# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "selo_ring/version"

Gem::Specification.new do |s|
  s.name        = "selo_ring_serviceable"
  s.version     = SeloRing::Serviceable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Selman ULUG"]
  s.email       = ["selman.ulug@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Abstrack service module for Rinda::RingServer}
  s.description = %q{Abstrack service module for Rinda::RingServer}

  s.add_development_dependency("minitest")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("watchr")
  s.add_development_dependency("rev")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
