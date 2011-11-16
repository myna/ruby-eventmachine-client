# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{myna-eventmachine}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Noel Welsh"]
  s.date = %q{2011-11-15}
  s.description = %q{Myna Ruby/Eventmachine Client Library}
  s.email = ["noel [at] mynaweb [dot] com"]
  s.files = ["Rakefile", "README", "lib/myna.rb", "test/test_myna.rb"]
  s.homepage = %q{http://www.mynaweb.com/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{myna-eventmachine}
  s.rubygems_version = %q{1.4.1}
  s.summary = %q{Ruby/EventMachine client library for Myna (http://www.mynaweb.com)}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
  end
end

