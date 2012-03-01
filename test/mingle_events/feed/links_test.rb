require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Feed
    
    class LinksTest < Test::Unit::TestCase
      def test_parse_links
        element_xml = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <category term="card" scheme="http://www.thoughtworks-studios.com/ns/mingle#categories"/>
            <link href="https://mingle.example.com/projects/atlas/cards/102" rel="http://www.thoughtworks-studios.com/ns/mingle#event-source" type="text/html" title="bug #103"/>
            <link href="https://mingle.example.com/api/v2/projects/atlas/cards/104.xml?version=7" rel="http://www.thoughtworks-studios.com/ns/mingle#version" type="application/vnd.mingle+xml" title="bug #105 (v7)"/>
          </entry>}
        links = Links.new(Xml.parse(element_xml, ATOM_AND_MINGLE_NS).select("/atom:entry"))
        assert_equal 2, links.count
        the_links = links.to_a
        assert_equal "https://mingle.example.com/projects/atlas/cards/102", the_links.first.href
        assert_equal "http://www.thoughtworks-studios.com/ns/mingle#event-source", the_links.first.rel
        assert_equal "text/html", the_links.first.type
        assert_equal "bug #103", the_links.first.title
        assert_equal "https://mingle.example.com/api/v2/projects/atlas/cards/104.xml?version=7", the_links.last.href
      end
      
      def test_find_by_rel_and_type
        element_xml = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <category term="card" scheme="http://www.thoughtworks-studios.com/ns/mingle#categories"/>
            <link href="https://mingle.example.com/projects/atlas/cards/102" rel="http://www.thoughtworks-studios.com/ns/mingle#related" type="text/html" title="bug #102"/>
            <link href="https://mingle.example.com/projects/atlas/cards/104" rel="http://www.thoughtworks-studios.com/ns/mingle#related" type="text/html" title="bug #104"/>
            <link href="https://mingle.example.com/projects/atlas/cards/104.xml" rel="http://www.thoughtworks-studios.com/ns/mingle#related" type="text/xml" title="bug #104"/>
            <link href="https://mingle.example.com/api/v2/projects/atlas/cards/104.xml?version=7" rel="http://www.thoughtworks-studios.com/ns/mingle#version" type="application/vnd.mingle+xml" title="bug #105 (v7)"/>
          </entry>}
        links = Links.new(Xml.parse(element_xml, ATOM_AND_MINGLE_NS).select("/atom:entry"))
        assert_equal ["bug #102", "bug #104"], links.find_by_rel_and_type(Links::RELATED_REL, "text/html").map(&:title)
      end

    end
    
  end
end
