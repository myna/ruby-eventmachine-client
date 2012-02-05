require 'rubygems'
require 'rake/testtask'

gemspec = Gem::Specification.new do |s|
  s.name              = 'myna-eventmachine'
  s.version           = '1.0.9'
  s.authors           = ['Noel Welsh']
  s.email             = ['noel [at] mynaweb [dot] com']
  s.homepage          = 'http://www.mynaweb.com/'
  s.rubyforge_project = 'myna'
  s.summary           = 'Ruby/EventMachine client library for Myna (http://www.mynaweb.com)'
  s.description       = File.read(File.expand_path(File.join(File.dirname(__FILE__), 'README.md')))

  s.add_dependency('json')

  s.files = ['Rakefile', 'README'] + Dir['lib/*.rb'] + Dir['test/*']
end

task :default => [:test]

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = false
end

task :gemspec do
  gemspec.validate
  File.open("#{gemspec.name}.gemspec", 'w'){|f| f.write gemspec.to_ruby }
end

task :build => :gemspec do
  system "gem build *.gemspec"
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "../release/ruby"
end

task :push => :build do
  system "gem push *.gem"
end
