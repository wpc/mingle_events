module MingleEvents  
  module Feed
    
    # The user who's Mingle activity triggered this event
    class Author
    
      include ElementSupport
  
      # The name of the author
      attr_reader :name
      # The email address of the author
      attr_reader :email
      # The URI identifying the author as well as location of his profile data
      attr_reader :uri
      # The URI for the author's icon
      attr_reader :icon_uri
  
      def initialize(author_element)
        @name = element_text(author_element, 'name')
        @email = element_text(author_element, 'email', true)
        @uri = element_text(author_element, 'uri', true)        
        @icon_uri = element_text(author_element, 'icon', true)
      end
      
      def self.from_xml_snippet(entry_xml)
        self.new(Nokogiri::XML(entry_xml).remove_namespaces!)        
      end
    
    end
      
  end
end



