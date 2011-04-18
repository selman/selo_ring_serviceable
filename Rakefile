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
