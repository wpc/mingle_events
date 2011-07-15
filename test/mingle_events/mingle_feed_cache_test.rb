require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class MingleFeedCacheTest < Test::Unit::TestCase
    
    def test_will_never_cache_latest_events
      source = LoggingStubMingleAccess.new(
        'http://example.com/api/v2/projects/foo/feeds/events.xml' => 'foo feed content'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml')
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml')
      source.assert_fetches([
        'http://example.com/api/v2/projects/foo/feeds/events.xml', 
        'http://example.com/api/v2/projects/foo/feeds/events.xml'
      ])
    end
    
    def test_scheme_and_host_and_port_are_ignored_when_determining_to_not_cache
      source = LoggingStubMingleAccess.new(
        'http://example.com/api/v2/projects/foo/feeds/events.xml' => 'foo feed content',
        '/api/v2/projects/foo/feeds/events.xml' => 'bogus but different feed content'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml')
      assert_equal 'bogus but different feed content', cache.fetch_page('/api/v2/projects/foo/feeds/events.xml')
      source.assert_fetches([
        'http://example.com/api/v2/projects/foo/feeds/events.xml', 
        '/api/v2/projects/foo/feeds/events.xml'
      ])
    end
    
    def test_will_never_cache_latest_events_with_app_context_and_absolute_paths
      source = LoggingStubMingleAccess.new(
        'http://example.com/context/api/v2/projects/foo/feeds/events.xml' => 'foo feed content'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/context/api/v2/projects/foo/feeds/events.xml')
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/context/api/v2/projects/foo/feeds/events.xml')
      source.assert_fetches([
        'http://example.com/context/api/v2/projects/foo/feeds/events.xml',
        'http://example.com/context/api/v2/projects/foo/feeds/events.xml'
      ])
    end
    
    def test_will_never_cache_latest_events_with_app_context_and_relative_paths
      source = LoggingStubMingleAccess.new(
        '/context/api/v2/projects/foo/feeds/events.xml' => 'foo feed content'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal 'foo feed content', cache.fetch_page('/context/api/v2/projects/foo/feeds/events.xml')
      assert_equal 'foo feed content', cache.fetch_page('/context/api/v2/projects/foo/feeds/events.xml')
      source.assert_fetches([
        '/context/api/v2/projects/foo/feeds/events.xml',
        '/context/api/v2/projects/foo/feeds/events.xml'
      ])
    end
    
    def test_will_cache_archived_event_pages_with_both_relative_and_absolute_paths
      source = LoggingStubMingleAccess.new(
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=23' => 'foo feed content'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml?page=23')
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml?page=23')
      assert_equal 'foo feed content', cache.fetch_page('/api/v2/projects/foo/feeds/events.xml?page=23')
      source.assert_fetches([
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=23'
      ])
    end
    
    def test_scheme_and_host_and_port_are_ignored_when_reading_from_cache_for_archived_event_pages
      source = LoggingStubMingleAccess.new(
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=23' => 'foo feed content'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal 'foo feed content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml?page=23')
      assert_equal 'foo feed content', cache.fetch_page('/api/v2/projects/foo/feeds/events.xml?page=23')
      source.assert_fetches([
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=23'
      ])
    end
    
    def test_query_is_correctly_cached
      source = LoggingStubMingleAccess.new(
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=23' => 'page 23 content',
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=24' => 'page 24 content'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal 'page 23 content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml?page=23')
      assert_equal 'page 23 content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml?page=23')
      assert_equal 'page 24 content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml?page=24')
      assert_equal 'page 24 content', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/events.xml?page=24')
      source.assert_fetches([
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=23',
        'http://example.com/api/v2/projects/foo/feeds/events.xml?page=24'
      ])
    end
        
    def test_will_not_cache_a_variety_of_other_url_patterns
      source = LoggingStubMingleAccess.new(
        'http://example.com/' => '1',
        'http://example.com/api/v2/projects/foo/feeds/another.xml' => '2',
        'http://example.com/api/v2/projects/foo/cards/execute_mql?MQL=boo' => '3'
      )
      cache = MingleFeedCache.new(source, temp_dir)
      assert_equal '1', cache.fetch_page('http://example.com/')
      assert_equal '1', cache.fetch_page('http://example.com/')
      assert_equal '2', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/another.xml')
      assert_equal '2', cache.fetch_page('http://example.com/api/v2/projects/foo/feeds/another.xml')
      assert_equal '3', cache.fetch_page('http://example.com/api/v2/projects/foo/cards/execute_mql?MQL=boo')
      assert_equal '3', cache.fetch_page('http://example.com/api/v2/projects/foo/cards/execute_mql?MQL=boo')
      source.assert_fetches([
        'http://example.com/',
        'http://example.com/',
        'http://example.com/api/v2/projects/foo/feeds/another.xml',
        'http://example.com/api/v2/projects/foo/feeds/another.xml',
        'http://example.com/api/v2/projects/foo/cards/execute_mql?MQL=boo',
        'http://example.com/api/v2/projects/foo/cards/execute_mql?MQL=boo'
      ])
    end
    
    class LoggingStubMingleAccess
      
      include Test::Unit::Assertions
            
      def initialize(content_by_path = {})
        @content_by_path = content_by_path
        @fetches = []
      end
      
      def fetch_page(path)
        @fetches << path
        @content_by_path[path]
      end
      
      def assert_fetches(fetches)
        assert_equal(fetches, @fetches)
      end
      
    end
    
  end
end