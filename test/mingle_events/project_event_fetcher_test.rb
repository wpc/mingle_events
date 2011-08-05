require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class ProjectEventFetcherTest < Test::Unit::TestCase
    
    def test_can_fetch_all_entries_and_write_to_disk_when_no_initial_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)  
      
      file_for_first_new_entry = fetcher.fetch_latest
      
      expected_entry_ids = [
        'https://mingle.example.com/projects/atlas/events/index/23',
        'https://mingle.example.com/projects/atlas/events/index/97',
        'https://mingle.example.com/projects/atlas/events/index/98',
        'https://mingle.example.com/projects/atlas/events/index/99',
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/103'
      ]
      
      assert_expected_entry_chain_written_to_disk(expected_entry_ids, file_for_first_new_entry, fetcher)      
    end
    
    def test_can_fetch_all_entries_and_write_to_disk_when_existing_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)
      setup_current_state(%{
<entry>
  <id>https://mingle.example.com/projects/atlas/events/index/97</id>
  <title>entry 97</title>
  <updated>2011-02-03T01:10:52Z</updated>
  <author><name>Harry</name></author>
</entry>}, fetcher)
      
      file_for_first_new_entry = fetcher.fetch_latest
      
      expected_entry_ids = [
        'https://mingle.example.com/projects/atlas/events/index/98',
        'https://mingle.example.com/projects/atlas/events/index/99',
        'https://mingle.example.com/projects/atlas/events/index/100',
        'https://mingle.example.com/projects/atlas/events/index/101',
        'https://mingle.example.com/projects/atlas/events/index/103'
      ]
      
      assert_expected_entry_chain_written_to_disk(expected_entry_ids, file_for_first_new_entry, fetcher)      
    end
    
    def test_no_new_entries_with_current_state
      state_dir = temp_dir
      fetcher = ProjectEventFetcher.new('atlas', stub_mingle_access, state_dir)
      setup_current_state(%{
<entry>
  <id>https://mingle.example.com/projects/atlas/events/index/103</id>
  <title>entry 103</title>
  <updated>2011-02-03T01:10:52Z</updated>
  <author><name>Harry</name></author>
</entry>}, fetcher)

      assert_nil fetcher.fetch_latest
      
      current_state = YAML.load(File.new(File.join(state_dir, 'current_state.yml')))
      assert_equal(@last_fetched_entry_info_file, current_state[:last_fetched_entry_info_file])
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
    
    def setup_current_state(last_fetched_entry_xml, fetcher)
      last_fetched_entry_info = {
        :entry_xml => last_fetched_entry_xml,
        :next_entry_file_path => nil
      }
      @last_fetched_entry_info_file = fetcher.file_for_entry(Feed::Entry.new(Nokogiri::XML(last_fetched_entry_xml).at('/entry')))
      FileUtils.mkdir_p(File.dirname(@last_fetched_entry_info_file))
      File.open(@last_fetched_entry_info_file, 'w') do |out|
        YAML.dump(last_fetched_entry_info, out)
      end
      current_state = {:last_fetched_entry_info_file => @last_fetched_entry_info_file}
      File.open(fetcher.current_state_file, 'w') do |out|
        YAML.dump(current_state, out)
      end

    end
    
    def assert_expected_entry_chain_written_to_disk(expected_entry_ids, file_for_first_new_entry, fetcher)
      
      file_for_new_entry = file_for_first_new_entry
      file_for_last_inspected_entry = nil
      expected_entry_ids.each_with_index do |expected_entry_id, index|
        file_for_last_inspected_entry = file_for_new_entry
        new_entry_info = YAML.load(File.new(file_for_new_entry))
        new_entry = Feed::Entry.new(Nokogiri::XML(new_entry_info[:entry_xml]).at('/entry'))
        assert_equal(expected_entry_id, new_entry.entry_id)
        file_for_new_entry = new_entry_info[:next_entry_file_path]
      end
      
      current_state = YAML.load(File.new(fetcher.current_state_file))
      assert_equal(file_for_last_inspected_entry, current_state[:last_fetched_entry_info_file])
      
    end
    
      
  end
end