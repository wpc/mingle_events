require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class ProjectEventFetcherTest < Test::Unit::TestCase
    
    def test_can_fetch_all_entries_and_write_to_disk_when_no_initial_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)  
      
      latest_entries = fetcher.fetch_latest
      expected_latest_entries = [23, 97, 98, 99, 100, 101, 103].map{|n| entry(n)}
      assert_equal(expected_latest_entries, latest_entries.to_a)
      assert_equal entry(23), fetcher.first_entry_fetched
      assert_equal entry(103), fetcher.last_entry_fetched
    end
    
    def test_can_fetch_all_entries_and_write_to_disk_when_existing_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)
      
      setup_current_state(23, 97, 97, fetcher)
      
      latest_entries = fetcher.fetch_latest
      expected_latest_entries = [98, 99, 100, 101, 103].map{|n| entry(n)}
      assert_equal(expected_latest_entries, latest_entries.to_a)
      assert_equal entry(23), fetcher.first_entry_fetched
      assert_equal entry(103), fetcher.last_entry_fetched
    end
    
    def test_no_new_entries_with_current_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)
      setup_current_state(23, 97, 103, fetcher)

      assert fetcher.fetch_latest.to_a.empty?
      assert_equal entry(23), fetcher.first_entry_fetched
      assert_equal entry(103), fetcher.last_entry_fetched
    end
    
    def test_no_new_entries_with_no_current_state
      state_dir = temp_dir
      mingle_access = StubMingleAccess.new
      mingle_access.register_page_content('/api/v2/projects/atlas/feeds/events.xml',%{
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
  <title>Mingle Events: Blank Project</title>
  <id>https://mingle.example.com/api/v2/projects/blank_project/feeds/events.xml</id>
  <link href="https://mingle.example.com/api/v2/projects/blank_project/feeds/events.xml" rel="current"/>
  <link href="https://mingle.example.com/api/v2/projects/blank_project/feeds/events.xml" rel="self"/>
  <updated>2011-08-04T19:42:04Z</updated>
</feed>})
      fetcher = ProjectEventFetcher.new('atlas', mingle_access, state_dir)
      
      assert fetcher.fetch_latest.to_a.empty?
      assert_nil fetcher.first_entry_fetched
      assert_nil fetcher.last_entry_fetched
    end
    
    private
    
    def setup_current_state(first_entry_id, second_entry_id, last_entry_id, fetcher)    
      first_entry = entry(first_entry_id)
      second_entry = entry(second_entry_id)
      last_entry = entry(last_entry_id)
      fetcher.write_entry_to_disk(first_entry, second_entry)
      fetcher.write_entry_to_disk(last_entry, nil)  
      fetcher.update_current_state(first_entry, last_entry)
    end
            
    def entry(entry_id)
      entry_xml = %{
        <entry>
          <id>https://mingle.example.com/projects/atlas/events/index/#{entry_id}</id>
          <title>entry #{entry_id}</title>
          <updated>2011-02-03T01:10:52Z</updated>
          <author><name>Bob</name></author>
        </entry>
      }
      Feed::Entry.new(Nokogiri::XML(entry_xml).at('/entry'))
    end
  end
end