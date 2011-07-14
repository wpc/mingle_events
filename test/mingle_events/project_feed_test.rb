require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class ProjectFeedTest < Test::Unit::TestCase
    
    def test_by_default_can_enumerate_entries_across_pages_starting_with_latest
      feed = ProjectFeed.from_now('atlas', stub_mingle_access)
      assert_equal([
        'https://mingle.example.com/projects/atlas/events/index/103',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/97',
        'https://mingle.example.com/projects/atlas/events/index/23'
        ], feed.entries.map(&:entry_id))
    end
    
    def test_can_enumerate_entries_across_pages_starting_with_oldest
      feed = ProjectFeed.from_the_beginning('atlas', stub_mingle_access)
      assert_equal([
        'https://mingle.example.com/projects/atlas/events/index/23',
        'https://mingle.example.com/projects/atlas/events/index/97',
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/103'
        ], feed.entries.map(&:entry_id))
    end
    
    
  end
end