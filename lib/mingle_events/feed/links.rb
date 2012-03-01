module MingleEvents
  module Feed
    
    class Links
      
      include Enumerable
      
      EVENT_SOURCE_REL = "http://www.thoughtworks-studios.com/ns/mingle#event-source"
      VERSION_REL = "http://www.thoughtworks-studios.com/ns/mingle#version"
      RELATED_REL = "http://www.thoughtworks-studios.com/ns/mingle#related"
      
      def initialize(entry_element)
        @links ||= entry_element.select_all("./atom:link").map do |link_element|
          Link.new(*%w(href rel type title).map { |name| link_element.attr(name) })
        end
      end
      
      def find_by_rel_and_type(rel, type)
        @links.select{|l| l.rel == rel && l.type == type}
      end
      
      def each(&block)
        @links.each{|l| yield l}
      end
      
      class Link
            
        attr_reader :href, :rel, :type, :title
      
        def initialize(href, rel, type, title)
          @href = href
          @rel = rel
          @type = type
          @title = title
        end
      end
      
    end
    
  end
  
end
