require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class ProjectEventFetcherTest < Test::Unit::TestCase
    
    def test_can_fetch_all_entries_and_write_to_disk_when_no_initial_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)  
      
      file_for_first_new_entry = fetcher.fetch_latest
      assert_expected_entry_chain_written_to_disk([23, 97, 98, 99, 100, 101, 103], file_for_first_new_entry, fetcher)         
      assert_equal 23, entry_id_for_file(fetcher.first_entry_fetched_file)
      assert_equal 103, entry_id_for_file(fetcher.last_entry_fetched_file)
    end
    
    def test_can_fetch_all_entries_and_write_to_disk_when_existing_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)
      
      setup_current_state(23, 97, 97, fetcher)
      
      file_for_first_new_entry = fetcher.fetch_latest
      assert_expected_entry_chain_written_to_disk([98, 99, 100, 101, 103], file_for_first_new_entry, fetcher)      
      assert_equal 23, entry_id_for_file(fetcher.first_entry_fetched_file)
      assert_equal 103, entry_id_for_file(fetcher.last_entry_fetched_file)
    end
    
    def test_no_new_entries_with_current_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)
      setup_current_state(23, 97, 103, fetcher)

      assert_nil fetcher.fetch_latest
      assert_equal 23, entry_id_for_file(fetcher.first_entry_fetched_file)
      assert_equal 103, entry_id_for_file(fetcher.last_entry_fetched_file)
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
      
      assert_nil fetcher.fetch_latest
      assert !File.exist?(File.join(state_dir, 'current_state.yml'))
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
    
    def assert_expected_entry_chain_written_to_disk(expected_entries, file_for_first_new_entry, fetcher)
   
      file_for_new_entry = file_for_first_new_entry
      file_for_last_inspected_entry = nil
      expected_entries.each_with_index do |expected_entry_id, index|
        file_for_last_inspected_entry = file_for_new_entry
        new_entry_info = YAML.load(File.new(file_for_new_entry))
        new_entry = Feed::Entry.new(Nokogiri::XML(new_entry_info[:entry_xml]).at('/entry'))
        assert_equal(expected_entry_id, new_entry.entry_id.split('/').last.to_i)
        file_for_new_entry = new_entry_info[:next_entry_file_path]
      end
    end
    
    def entry_id_for_file(filename)
      entry = Feed::Entry.new(Nokogiri::XML(YAML.load(File.new(filename))[:entry_xml]).at('/entry'))
      entry.entry_id.split('/').last.to_i
    end
    
    def entry(entry_id)
      Feed::Entry.new(Nokogiri::XML(entry_xml(entry_id)).at('/entry'))
    end
    
    def entry_xml(entry_id)
      %{
        <entry>
          <id>https://mingle.example.com/projects/atlas/events/index/#{entry_id}</id>
          <title>entry #{entry_id}</title>
          <updated>2011-02-03T01:10:52Z</updated>
          <author><name>Bob</name></author>
        </entry>
      }
    end
      
  end
end