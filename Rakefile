require 'rake'
require 'rake/testtask'
# require 'echoe'

require 'lib/mingle_events'

task :default => [:test, :clean]

desc "Run tests"
Rake::TestTask.new do |task|
  task.pattern = 'test/**/*_test.rb'
  task.verbose = true
  task.warning = true
end
 
# Echoe.new('mingle-events', '0.0.1') do |p|
#   p.description    = "A gem that lets you process Mingle events in a pipes and filters style."
#   p.url            = "https://github.com/ThoughtWorksStudios/mingle-events"
#   p.author         = "David Rice"
#   p.email          = "david.rice at gmail dot com"
#   p.ignore_pattern = ["test/**/*.rb", "high_level_design.graffle", "stories.textile", "Rakefile"]
#   p.development_dependencies = []
# end

task :clean do
  FileUtils.rm_rf('test/tmp')
end

task :poll_once_example do
  
  state_folder = File.join(File.dirname(__FILE__), 'example_app_state') 
  cache_folder = File.join(File.dirname(__FILE__), 'example_app_feed_cache') 
  
  FileUtils.rm_rf(state_folder) if ENV['CLEAN'] == 'true'
  FileUtils.rm_rf(cache_folder) if ENV['CLEAN'] == 'true'
  
  mingle_access = MingleEvents::MingleBasicAuthAccess.new(
    'https://mingle.example.com:7071',
    ENV['MINGLE_USER'],
    ENV['MINGLE_PASSWORD']
  )
  mingle_access_cache = MingleEvents::MingleFeedCache.new(mingle_access, cache_folder)
    
  card_data = MingleEvents::Processors::CardData.new(mingle_access_cache, 'test_project')
      
  log_commenting_on_high_priority_stories = MingleEvents::Processors::Pipeline.new([
      card_data,
      MingleEvents::Processors::CardTypeFilter.new(['Story'], card_data),
      MingleEvents::Processors::CustomPropertyFilter.new('Priority', 'High', card_data),
      MingleEvents::Processors::CategoryFilter.new([MingleEvents::Category::COMMENT_ADDITION]),
      MingleEvents::Processors::PutsPublisher.new
    ])
    
  processors_by_project = {
    'test_project' => [log_commenting_on_high_priority_stories]
  }
    
  MingleEvents::Poller.new(mingle_access_cache, processors_by_project, state_folder, true).run_once  
end

task :poll_local_mingle do
  
  state_folder = '/Users/djrice/.mingle-events/local7070/event_tester/event_state' 
  cache_folder = '/Users/djrice/.mingle-events/local7070/event_tester/mingle_cache'
  
  FileUtils.rm_rf(state_folder) if ENV['CLEAN'] == 'true'
  FileUtils.rm_rf(cache_folder) if ENV['CLEAN'] == 'true'
  
  mingle_access = MingleEvents::MingleBasicAuthAccess.new(
    'https://localhost:7071',
    'david',
    'p'
  )
  mingle_access_cache = MingleEvents::MingleFeedCache.new(mingle_access, cache_folder)
    
  card_data = MingleEvents::Processors::CardData.new(mingle_access_cache, 'event_tester')
      
  pipeline = MingleEvents::Processors::Pipeline.new([
      # card_data,
      # MingleEvents::Processors::CategoryFilter.new([MingleEvents::Category::COMMENT_ADDITION]),
      MingleEvents::Processors::PutsPublisher.new
    ])
    
  processors_by_project = {
    'event_tester' => [pipeline]
  }
    
  MingleEvents::Poller.new(mingle_access_cache, processors_by_project, state_folder, true).run_once  
end

task :poll_mingle do
  
  state_folder = '/Users/djrice/mingle_data/mingle_event_state' 
  cache_folder = '/Users/djrice/mingle_data/mingle_app_feed_cache'
  
  FileUtils.rm_rf(state_folder) if ENV['CLEAN'] == 'true'
  FileUtils.rm_rf(cache_folder) if ENV['CLEAN'] == 'true'
  
  mingle_access = MingleEvents::MingleBasicAuthAccess.new(
    'https://mingle09.thoughtworks.com',
    ENV['MINGLE_USER'],
    ENV['MINGLE_PASSWORD']
  )
  mingle_access_cache = MingleEvents::MingleFeedCache.new(mingle_access, cache_folder)
    
  card_data = MingleEvents::Processors::CardData.new(mingle_access_cache, 'mingle')
      
  pipeline = MingleEvents::Processors::Pipeline.new([
      card_data,
      MingleEvents::Processors::CategoryFilter.new([MingleEvents::Category::COMMENT_ADDITION]),
      MingleEvents::Processors::PutsPublisher.new
    ])
    
  processors_by_project = {
    'mingle' => [pipeline]
  }
    
  MingleEvents::Poller.new(mingle_access_cache, processors_by_project, state_folder).run_once  
end