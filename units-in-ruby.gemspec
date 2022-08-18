# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "units-in-ruby"
  s.version     = '0.0.3'
  s.authors     = ["Brandon Fosdick", "Meseker Yohannes"]
  s.email       = ["bfoz@bfoz.net"]
  s.homepage    = 'http://github.com/bfoz/units-ruby'
  s.summary     = %q{Extends Numeric to add support for tracking units of measure}
  s.description = %q{Extends Numeric to add support for tracking units of measure}
  s.required_ruby_version = ">= 2.7.6", "< 3.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "cmath"
  s.add_dependency "matrix"
  s.add_development_dependency "minitest"
end
