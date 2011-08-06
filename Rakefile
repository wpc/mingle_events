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

task :poll_and_process_once_example do
      
  mingle_access = MingleEvents::MingleBasicAuthAccess.new('https://localhost:7071', 'david', 'p')
    
  card_data = MingleEvents::Processors::CardData.new(mingle_access, 'test_project')     
  log_commenting_on_high_priority_stories = MingleEvents::Processors::Pipeline.new([
      card_data,
      MingleEvents::Processors::CardTypeFilter.new(['Story'], card_data),
      MingleEvents::Processors::CustomPropertyFilter.new('Priority', 'High', card_data),
      MingleEvents::Processors::CategoryFilter.new([MingleEvents::Category::COMMENT_ADDITION]),
      MingleEvents::Processors::PutsPublisher.new
    ])
        
  MingleEvents::Poller.new(mingle_access, {'test_project' => [log_commenting_on_high_priority_stories]}).run_once  
end

task :poll_and_log_example do
  rmdir_on_clean("~/.mingle-events/localhost")
  mingle_access = MingleEvents::MingleBasicAuthAccess.new('https://localhost:7071', 'david', 'p')
  MingleEvents::Poller.new(mingle_access, {'blank_project' => [MingleEvents::Processors::PutsPublisher.new]}).run_once  
end

