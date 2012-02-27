module MingleEvents
  module Feed
  
    # A Ruby wrapper around an Atom entry, particularly an Atom entry
    # representing an event in Mingle.
    class Entry
      
      # Construct with the wrapped Xml Elem for the entry
      def initialize(entry_element)
        @entry_element = entry_element
      end
      
      def self.from_snippet(entry_xml)
        self.new(Xml.parse(entry_xml))
      end
  
      # The raw entry XML from the Atom feed
      def raw_xml
        @raw_xml ||= Xml.raw_xml(@entry_element)
      end
  
      # The Atom entry's id value. This is the one true identifier for the entry,
      # and therefore the event.
      def entry_id
        @entry_id ||= Xml.inner_text(@entry_element, "id")
      end
      alias :event_id :entry_id
  
      # The Atom entry's title
      def title
        @title ||= Xml.inner_text(@entry_element, 'title')
      end
  
      # The time at which entry was created, i.e., the event was triggered
      def updated
        @updated ||= Time.parse(Xml.inner_text(@entry_element, "updated"))
      end
  
      # The user who created the entry (triggered the event), i.e., changed project data in Mingle
      def author
        @author ||= Author.new(Xml.select(@entry_element, "author"))
      end
    
      # The set of Atom categoies describing the entry
      def categories
        @categories ||= Xml.select_all(@entry_element, "category").map do |category_element|
          Category.new(Xml.attr(category_element, "term"), Xml.attr(category_element, "scheme"))
        end
      end
      
      # The array of changes for this entry. Each change is a hash with redundant :type and
      # :category entries specifying the category to which the change maps.  
      # Change detail is contained in nested hashes with keys mapping exactly to the XML
      # as described in http://www.thoughtworks-studios.com/mingle/3.3/help/mingle_api_events.html. 
      # The data in the change hashes reflect only what is in the XML as encriching them would 
      # require potentially many calls to the Mingle server resulting in very slow processing. 
      def changes
        @changes ||= Changes.new(Xml.select(@entry_element,"content/changes"))
      end
  
      # Whether the entry/event was sourced by a Mingle card
      def card?
        categories.any?{|c| c == Category::CARD}
      end
  
      # The number of the card that sourced this entry/event. If the entry is not a card event
      # an error will be thrown. The source of this data is perhaps not so robust and we'll need
      # to revisit this in the next release of Mingle.
      def card_number
        raise "You cannot get the card number for an event that is not sourced by a card!" unless card?
        @card_number ||= parse_card_number
      end
      
      # The version number of the card or page that was created by this event. (For now, only 
      # working with cards.)
      def version
        @version ||= CGI.parse(URI.parse(card_version_resource_uri).query)["version"].first.to_i
      end
  
      # The resource URI for the card version that was created by this event. Throws error if not card event.
      def card_version_resource_uri
        raise "You cannot get card version data for an event that is not sourced by a card!" unless card?      
        @card_version_resource_uri ||= parse_card_version_resource_uri
      end
      
      def links
        Links.new(@entry_element)
      end
  
      def to_s
        "Entry[entry_id=#{entry_id}, updated=#{updated}]"
      end
      
      def eql?(object)
        if object.equal?(self)
         return true
        elsif !self.class.equal?(object.class)
         return false
        end
      
        return object.entry_id == entry_id
      end
      
      def ==(object)
        eql?(object)
      end
  
      private
  
      def parse_card_number
        card_number_element = Xml.select(@entry_element,
                                         "link[@rel='http://www.thoughtworks-studios.com/ns/mingle#event-source'][@type='application/vnd.mingle+xml']")
        # TODO: improve this bit of parsing :)
        Xml.attr(card_number_element, "href").split('/').last.split('.')[0..-2].join.to_i
      end
  
      def parse_card_version_resource_uri
        card_number_element = Xml.select(@entry_element, 
                                         "link[@rel='http://www.thoughtworks-studios.com/ns/mingle#version'][@type='application/vnd.mingle+xml']")
        Xml.attr(card_number_element, "href")
      end
    end
    
  end
end
