require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Feed
    
    class PageTest < Test::Unit::TestCase
    
      def test_entries_are_enumerable   
        latest_entries_page = Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml', stub_mingle_access)
      
        assert_equal([
          'https://mingle.example.com/projects/atlas/events/index/103',
          'https://mingle.example.com/projects/atlas/events/index/101',
          'https://mingle.example.com/projects/atlas/events/index/100'
          ], latest_entries_page.entries.map(&:entry_id))  
      end
    
      def test_next_page_returns_the_page_of_entries_as_specified_by_next_link
        latest_entries_page = Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml', stub_mingle_access)
        next_page = latest_entries_page.next
        assert_equal('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2', next_page.url)
        assert_equal('https://mingle.example.com/projects/atlas/events/index/99', next_page.entries.first.entry_id)
      end
    
      def test_next_page_when_on_last_page
        last_page = Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1', stub_mingle_access)
        assert_nil(last_page.next)
      end
    
      def test_previous_page_returns_the_page_of_entries_as_specified_by_previous_link
        current_page = Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1', stub_mingle_access)
        previous_page = current_page.previous
        assert_equal('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2', previous_page.url)
        assert_equal('https://mingle.example.com/projects/atlas/events/index/99', previous_page.entries.first.entry_id)
      end
    
      def test_previous_page_when_on_latest_entries
        latest_entries_page = Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml', stub_mingle_access)
        assert_nil(latest_entries_page.previous)
      end
    
      def test_can_determine_whether_archived
        assert !Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml', stub_mingle_access).archived?
        assert !Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3', stub_mingle_access).archived?
        assert Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1', stub_mingle_access).archived?
      end
    
      def test_can_determine_closest_archived_page
        assert_equal 'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2',
          Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml', stub_mingle_access).closest_archived_page.url
        assert_equal 'https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2',
          Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2', stub_mingle_access).closest_archived_page.url      
      end
    
      def test_can_determine_when_there_is_no_closest_archived_page
        mingle_access = StubMingleAccess.new
        mingle_access.register_page_content('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1',
          %{
  <feed xmlns="http://www.w3.org/2005/Atom" xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
    <link href="https://mingle.example.com/api/v2/projects/event_tester/feeds/events.xml" rel="current"/>
    <link href="https://mingle.example.com/api/v2/projects/event_tester/feeds/events.xml" rel="self"/>
    <entry>
      <id>https://mingle.example.com/projects/event_tester/events/index/390</id>
      <title>Card #2 Card Two created</title>
      <updated>2011-08-02T22:27:38Z</updated>
      <author><name>David</name></author>
    </entry>
    <entry>
      <id>https://mingle.example.com/projects/event_tester/events/index/389</id>
      <title>Card #1 Card One created</title>
      <updated>2011-08-02T22:27:36Z</updated>
      <author><name>David</name></author>
    </entry>
  </feed>          
          })
        assert_nil Page.new('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1', mingle_access).closest_archived_page
      end
  
    end
  
  end
end