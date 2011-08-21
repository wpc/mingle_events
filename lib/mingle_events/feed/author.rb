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
        @name = element_inner_text(author_element, 'name')
        @email = element_inner_text(author_element, 'email', true)
        @uri = element_inner_text(author_element, 'uri', true)        
        @icon_uri = element_inner_text(author_element, 'icon', true)
      end
      
      def self.from_snippet(entry_xml)
        self.new(Nokogiri::XML(entry_xml))        
      end
      
      private 
      
      def element_inner_text(parent_element, element_name, optional = false)
        element = parent_element.at(element_name)
        if optional && element.nil?
          nil
        else
          element.inner_text
        end
      end
    
    end
      
  end
end



