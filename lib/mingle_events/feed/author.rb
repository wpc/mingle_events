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
        @name = Xml.inner_text(author_element, "name")
        @email, @uri, @icon_uri = *%w(email uri icon).map do |path|
          Xml.optional_inner_text(author_element, path)
        end
      end

      def self.from_snippet(entry_xml)
        self.new(Xml.parse(entry_xml))
      end
    end

  end
end
