# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "devise_yolk/version"

Gem::Specification.new do |s|
  s.name        = "devise_yolk"
  s.version     = DeviseYolk::VERSION
  s.authors     = ["Dominik Steiner"]
  s.email       = ["dominik.j.steiner@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Yolk authentication for Devise}
  s.description = %q{Yolk authentication for Devise}

  s.rubyforge_project = "devise_yolk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency %q<activesupport>
  s.add_runtime_dependency(%q<devise>, [">= 2.1.0"])
end
