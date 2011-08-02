require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class ProjectFeedTest < Test::Unit::TestCase
    
    def test_can_enumerate_all_entries_across_pages_when_no_initial_state
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      assert_equal([
        'https://mingle.example.com/projects/atlas/events/index/23',
        'https://mingle.example.com/projects/atlas/events/index/97',
        'https://mingle.example.com/projects/atlas/events/index/98',
        'https://mingle.example.com/projects/atlas/events/index/99',
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/103'
        ], feed.entries_beyond(nil, nil).map(&:entry_id))
    end
    
    def test_can_enumerate_all_entries_across_pages_beyond_last_seen_event_in_middle_of_page
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      assert_equal([
        'https://mingle.example.com/projects/atlas/events/index/99',
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/103'
        ], feed.entries_beyond(
              'https://mingle.example.com/projects/atlas/events/index/98',
              'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2').map(&:entry_id))
    end
    
    def test_can_enumerate_all_entries_across_pages_beyond_last_seen_event_at_end_of_page
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      assert_equal([
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/103'
        ], feed.entries_beyond( 
              'https://mingle.example.com/projects/atlas/events/index/99', 
              'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2').map(&:entry_id))
    end
    
    def test_no_new_entries
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      assert_equal([], feed.entries_beyond(                      
            'https://mingle.example.com/projects/atlas/events/index/103', 
            'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3').map(&:entry_id))
    end
    
    def test_can_get_get_most_recent_entry
      feed = ProjectFeed.new('atlas', stub_mingle_access)
      assert_equal 'https://mingle.example.com/projects/atlas/events/index/103', feed.most_recent_entry.entry_id
    end
      
  end
end