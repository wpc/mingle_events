module MingleEvents  
  module Feed
    
    # The user who's Mingle activity triggered this event
    class Author
      
      # The name of the author
      attr_reader :name
      # The email address of the author
      attr_reader :email
      # The URI identifying the author as well as location of his profile data
      attr_reader :uri
      # The URI for the author's icon
      attr_reader :icon_uri
  
      def initialize(author_element)
        @name = author_element.at("name").inner_text
        @email = optional_element_text(author_element, 'email')
        @uri = optional_element_text(author_element, 'uri')        
        @icon_uri = optional_element_text(author_element, 'icon')
      end
      
      def self.from_snippet(entry_xml)
        self.new(Nokogiri::XML(entry_xml))        
      end
      
      private 
      
      def optional_element_text(parent_element, element_name)
        element = parent_element.at(element_name)
        element.nil? ? nil : element.inner_text
      end
    
    end
      
  end
end



