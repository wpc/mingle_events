require 'test/unit'

require 'ostruct'
require 'fileutils'

require 'rubygems'
require 'active_support'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'mingle_events'))

MingleEvents.log.level = Logger::WARN

class Test::Unit::TestCase 
  
  EMPTY_EVENTS_XML = %{
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom" xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
      <title>Mingle Events: Blank Project</title>
      <id>https://mingle.example.com/api/v2/projects/blank_project/feeds/events.xml</id>
      <link href="https://mingle.example.com/api/v2/projects/blank_project/feeds/events.xml" rel="current"/>
      <link href="https://mingle.example.com/api/v2/projects/blank_project/feeds/events.xml" rel="self"/>
      <updated>2011-08-04T19:42:04Z</updated>
    </feed>
  }
  
  # page 3
  LATEST_EVENTS_XML = %{
    <feed xmlns="http://www.w3.org/2005/Atom" xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
    
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml" rel="current"/>
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml" rel="self"/>
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2" rel="next"/>
      
      <entry>
        <id>https://mingle.example.com/projects/atlas/events/index/103</id>
        <title>entry 103</title>
        <updated>2011-02-03T08:12:42Z</updated>
        <author><name>Bob</name></author>
      </entry>
      <entry>
        <id>https://mingle.example.com/projects/atlas/events/index/101</id>
        <title>entry 101</title>
        <updated>2011-02-03T02:09:16Z</updated>
        <author><name>Bob</name></author>
      </entry>
      <entry>
        <id>https://mingle.example.com/projects/atlas/events/index/100</id>
        <title>entry 100</title>
        <updated>2011-02-03T01:58:02Z</updated>
        <author><name>Mary</name></author>
      </entry>
    </feed>
  }  
   
  # page 2
  PAGE_2_EVENTS_XML = %{
    <feed xmlns="http://www.w3.org/2005/Atom" xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
    
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml" rel="current"/>
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2" rel="self"/>
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1" rel="next"/>
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3" rel="previous"/>
      
      <entry>
        <id>https://mingle.example.com/projects/atlas/events/index/99</id>
        <title>entry 99</title>
        <updated>2011-02-03T01:30:52Z</updated>
        <author><name>Harry</name></author>
      </entry>
      
      <entry>
        <id>https://mingle.example.com/projects/atlas/events/index/98</id>
        <title>entry 98</title>
        <updated>2011-02-03T01:20:52Z</updated>
        <author><name>Harry</name></author>
      </entry>
      
      <entry>
        <id>https://mingle.example.com/projects/atlas/events/index/97</id>
        <title>entry 97</title>
        <updated>2011-02-03T01:10:52Z</updated>
        <author><name>Harry</name></author>
      </entry>
    </feed>
  }    
    
  # page 1
  PAGE_1_EVENTS_XML = %{
    <feed xmlns="http://www.w3.org/2005/Atom" xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
    
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml" rel="current"/>
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1" rel="self"/>
      <link href="https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2" rel="previous"/>
      
      <entry>
        <id>https://mingle.example.com/projects/atlas/events/index/23</id>
        <title>entry 23</title>
        <updated>2011-02-01T01:00:52Z</updated>
        <author><name>Bob</name></author>
      </entry>
    </feed>
  }      
  
  def stub_mingle_access
    stub = StubMingleAccess.new
    stub.register_page_content('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml', LATEST_EVENTS_XML)
    stub.register_page_content('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=2', PAGE_2_EVENTS_XML)
    stub.register_page_content('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=1', PAGE_1_EVENTS_XML)
    stub.register_page_content('https://mingle.example.com/api/v2/projects/atlas/feeds/events.xml?page=3', LATEST_EVENTS_XML)
    stub.register_page_content('/api/v2/projects/atlas/feeds/events.xml', LATEST_EVENTS_XML)
    stub.register_page_content('/api/v2/projects/atlas/feeds/events.xml?page=2', PAGE_2_EVENTS_XML)
    stub.register_page_content('/api/v2/projects/atlas/feeds/events.xml?page=1', PAGE_1_EVENTS_XML)
    stub.register_page_content('/api/v2/projects/atlas/feeds/events.xml?page=3', LATEST_EVENTS_XML)

    stub
  end 
  
  def temp_dir
    path = File.expand_path(File.join(File.dirname(__FILE__), 'tmp',  ::SecureRandom.hex(16)))
    FileUtils.mkdir_p(path)
    path
  end

  def temp_file
    File.join(temp_dir, ::SecureRandom.hex(16))
  end

  class StubMingleAccess

    def initialize
      @pages_by_path = {}
      @not_found_pages = []
      @exploding_pages = []
    end
    
    def base_url
      'http://example.com/mingle'
    end

    def register_page_content(path, content)
      @pages_by_path[path] = content
    end

    def register_page_not_found(path)
      @not_found_pages << path
    end
    
    def register_explosion(path)
      @exploding_pages << path
    end

    def fetch_page(path)
      if @not_found_pages.include?(path)
        rsp = Net::HTTPNotFound.new(nil, '404', 'Page not found!')
        def rsp.body
          "404!!!!!"
        end
        raise MingleEvents::HttpError.new(rsp, path)
      end
      
      if @exploding_pages.include?(path)
        rsp = Net::HTTPNotFound.new(nil, '500', 'Server exploded!')
        def rsp.body
          "500!!!!!"
        end
        raise MingleEvents::HttpError.new(rsp, path)
      end

      raise "Attempting to fetch page at #{path}, but your test has not registered content for this path! Registered paths: #{@pages_by_path.keys.inspect}" unless @pages_by_path.key?(path)
      @pages_by_path[path]
    end

  end

  class StubProjectCustomProperties

    def initialize(property_names_by_column_names) 
      @property_names_by_column_names = property_names_by_column_names
    end

    def property_name_for_column(column_name)
      @property_names_by_column_names[column_name]
    end

  end

end
