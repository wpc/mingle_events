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
        @name = author_element.inner_text("./atom:name")
        @email = author_element.optional_inner_text("./atom:email")
        @uri = author_element.optional_inner_text("./atom:uri")
        @icon_uri = author_element.optional_inner_text("./mingle:icon")
      end

      def self.from_snippet(author_xml)
        self.new(Xml.parse(author_xml, ATOM_AND_MINGLE_NS).select("/atom:author"))
      end
    end

  end
end
