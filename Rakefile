require 'rake'
require 'rake/testtask'

require 'lib/mingle_events'

task :default => [:test, :clean]

desc "Run tests"
Rake::TestTask.new do |task|
  task.pattern = 'test/**/*_test.rb'
  task.verbose = true
  task.warning = true  
end
 
def rmdir_on_clean(dir)
  FileUtils.rm_rf(File.expand_path(dir)) if ENV['CLEAN'] == 'true'
end

task :clean do
  FileUtils.rm_rf('test/tmp')
end

task :readme_example do
  
  rmdir_on_clean("~/.mingle_events/localhost")
  
  # configure access to mingle
  mingle_access = MingleEvents::MingleBasicAuthAccess.new('https://localhost:7071', 'david', 'p')
    
  # assemble processing pipeline
  post_comments_to_another_service = MingleEvents::Processors::Pipeline.new([
    MingleEvents::Processors::CategoryFilter.new([MingleEvents::Feed::Category::COMMENT_ADDITION]),
    MingleEvents::Processors::HttpPostPublisher.new('http://localhost:4567/')
  ])
        
  # poll once
  MingleEvents::Poller.new(mingle_access, {'test_project' => [post_comments_to_another_service]}).run_once  
end

task :poll_and_log_example do
  rmdir_on_clean("~/.mingle_events/localhost")
  mingle_access = MingleEvents::MingleBasicAuthAccess.new('https://localhost:7071', 'david', 'p')
  MingleEvents::Poller.new(mingle_access, {'blank_project' => [MingleEvents::Processors::PutsPublisher.new]}).run_once  
end

