require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class ProjectEventBroadcasterTest < Test::Unit::TestCase
    
    def test_can_process_all_events_from_beginning_of_time_on_initialization
      processor = DummyProcessor.new
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      state_file = temp_file
      event_broadcaster = ProjectEventBroadcaster.new(feed, [processor], state_file, :from_beginning_of_time)
      event_broadcaster.run_once
      
      assert_equal(7, processor.processed_events.count)
      assert_equal '103', YAML.load(File.new(state_file))[:last_entry].split('/').last
    end
    
    def test_can_initialize_for_all_future_events
      processor = DummyProcessor.new
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      state_file = temp_file
      event_broadcaster = ProjectEventBroadcaster.new(feed, [processor], state_file, :from_now)
      event_broadcaster.run_once
      
      assert_equal(0, processor.processed_events.count)
      assert_equal '103', YAML.load(File.new(state_file))[:last_entry].split('/').last
    end
    
    def test_can_process_only_recent_history
      processor = DummyProcessor.new
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      state_file = temp_file
      File.open(state_file, 'w') do |out|
        YAML.dump({
          :last_entry => 'https://mingle.example.com/projects/atlas/events/index/100',
          :last_page => 'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3'}, out)
      end
      event_broadcaster = ProjectEventBroadcaster.new(feed, [processor], state_file, :from_now)
      event_broadcaster.run_once
      
      assert_equal(2, processor.processed_events.count)
      assert_equal '103', YAML.load(File.new(state_file))[:last_entry].split('/').last
    end
    
    def test_initializes_successfully_when_project_has_no_events_and_initializing_from_beginning_of_time
      feed = DummyNoEventProjectFeed.new
      state_file = temp_file
      event_broadcaster = ProjectEventBroadcaster.new(feed, [], state_file, :from_beginning_of_time)
      event_broadcaster.run_once
     
      state = YAML.load(File.new(state_file))
      assert_nil state[:last_entry]
      assert_nil state[:last_page]
    end
    
    def test_initializes_successfully_when_project_has_no_events_and_initializing_from_now
      feed = DummyNoEventProjectFeed.new
      state_file = temp_file
      event_broadcaster = ProjectEventBroadcaster.new(feed, [], state_file, :from_now)
      event_broadcaster.run_once
     
      state = YAML.load(File.new(state_file))
      assert_nil state[:last_entry]
      assert_nil state[:last_page]
    end
        
    def test_does_nothing_when_no_new_events
      processor = DummyProcessor.new
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      state_file = temp_file
      File.open(state_file, 'w') do |out|
        YAML.dump({
          :last_entry => 'https://mingle.example.com/projects/atlas/events/index/103',
          :last_page => 'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3'}, out)
      end
      event_broadcaster = ProjectEventBroadcaster.new(feed, [processor], state_file, :from_now)
      event_broadcaster.run_once
      
      assert_equal(0, processor.processed_events.count)
      assert_equal '103', YAML.load(File.new(state_file))[:last_entry].split('/').last
    end
    
    def test_publishes_to_all_subscribers
      processor_1 = DummyProcessor.new
      processor_2 = DummyProcessor.new
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      state_file = temp_file
      File.open(state_file, 'w') do |out|
        YAML.dump({
          :last_entry => 'https://mingle.example.com/projects/atlas/events/index/100',
          :last_page => 'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3'}, out)
      end
      event_broadcaster = ProjectEventBroadcaster.new(feed, [processor_1, processor_2], state_file, :from_now)
      event_broadcaster.run_once
      
      assert_equal(2, processor_1.processed_events.count)
      assert_equal(2, processor_2.processed_events.count)
    end
    
    def test_failure_during_processing_stops_processing
      processor_1 = DummyProcessor.new
      processor_2 = DummyProcessor.new
      def processor_1.process_event(event)
        raise "Explode!" if event.entry_id == 'https://mingle.example.com/projects/atlas/events/index/103'
        super
      end
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      state_file = temp_file
      File.open(state_file, 'w') do |out|
        YAML.dump({
          :last_entry => 'https://mingle.example.com/projects/atlas/events/index/100',
          :last_page => 'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3'}, out)
      end
      event_broadcaster = ProjectEventBroadcaster.new(feed, [processor_1, processor_2], state_file, :from_now, DummyLogger.new)
      event_broadcaster.run_once
      
      assert_equal(1, processor_1.processed_events.count)
      assert_equal '101', YAML.load(File.new(state_file))[:last_entry].split('/').last    
    end
        
    class DummyProcessor
      
      attr_reader :processed_events
      
      def initialize
        @processed_events = []
      end
      
      def process_events(events)
        events.each{|e| process_event(e)}
      end
      
      def process_event(event)
        @processed_events << event
      end
      
    end
    
    class DummyNoEventProjectFeed
      def most_recent_entry
        nil
      end
      
      def entries_beyond(last_entry, last_page)
        []
      end
    end
    
    class DummyLogger
      
      def error(message)
        
      end
    end
     
  end
end