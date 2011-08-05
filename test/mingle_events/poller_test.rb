require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class PollerTest < Test::Unit::TestCase
    
    def test_sends_all_events_to_all_processors
      state_folder = temp_dir
      mingle_access = stub_mingle_access
      processor_1 = DummyProcessor.new
      processor_2 = DummyProcessor.new
      poller = Poller.new(mingle_access, {'atlas' => [processor_1, processor_2]})
      poller.run_once(:clean => true)
      
      expected_entry_ids = [
        'https://mingle.example.com/projects/atlas/events/index/23',
        'https://mingle.example.com/projects/atlas/events/index/97',
        'https://mingle.example.com/projects/atlas/events/index/98',
        'https://mingle.example.com/projects/atlas/events/index/99',
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/103'
      ]
      
      [processor_1, processor_2].each do |processor|
        assert_equal(expected_entry_ids, processor.processed_events.map(&:entry_id))
      end
    end
  
    class DummyProcessor 
      
      def initialize
        @processed_events = []
      end
      
      def process_events(events)
        @processed_events = @processed_events + events
      end
      
      def processed_events
        @processed_events
      end
      
    end
    
  end
  
end