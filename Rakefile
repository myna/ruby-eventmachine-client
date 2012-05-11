require 'rubygems'
require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

task :default => [:test]

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = false
end
