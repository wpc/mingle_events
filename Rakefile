require 'rake'
require 'rake/testtask'


task :default => [:test, :clean]

desc "Run tests"
Rake::TestTask.new do |task|
  task.pattern = 'test/**/*_test.rb'
  task.verbose = true
  task.warning = true  
end
 
task :clean do
  FileUtils.rm_rf('test/tmp')
end



