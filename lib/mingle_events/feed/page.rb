module MingleEvents
  module Feed
  
    # A page of Atom events. I.e., *not* a Mingle page. Most users of this library
    # will not use this class to access the Mingle Atom feed, but will use the 
    # ProjectFeed class which handles paging transparently.
    class Page
  
      attr_accessor :url
    
      def initialize(url, mingle_access)
        @url = url
        @mingle_access = mingle_access
      end
  
      def entries
        @entries ||= page_as_document.search('entry').map do |entry_element|
          Entry.new(entry_element)
        end
      end
  
      def next
        next_url_element = page_as_document.at("link[@rel='next']")
        if next_url_element.nil?
          nil
        else
          Page.new(next_url_element["href"], @mingle_access)
        end
      end
  
      private    
  
      def page_as_document
        @page_as_document ||= Nokogiri::XML(@mingle_access.fetch_page(@url)).remove_namespaces!
      end
    
    end
    
  end
end