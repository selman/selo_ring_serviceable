require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.name = :spec
  t.pattern = 'spec/*_spec.rb'
  t.libs << %w(spec)
  t.warning = true
end

task :default => :spec

desc "run watchr"
task :watchr do
  system "watchr specs.watchr"
end

begin
  require 'flog_task'
  FlogTask.new(:flog, 445)
rescue LoadError
end

begin
  require 'flay_task'
  FlayTask.new(:flay, 445)
rescue LoadError
end
