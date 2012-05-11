# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "myna/version"

Gem::Specification.new do |s|
  s.name        = 'myna_eventmachine'
  s.version     = Myna::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2012-05-11'
  s.summary     = 'Ruby/EventMachine client library for Myna (http://www.mynaweb.com)'
  s.authors     = ["Noel Welsh"]
  s.description = 'An EventMachine based client for '
  s.email       = ["noel [at] untyped [dot] com"]
  s.files       = ["lib/myna.rb"]
  s.homepage    = 'http://www.mynaweb.com/'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
