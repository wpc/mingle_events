require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  class XmlTest < Test::Unit::TestCase
    def test_get_inner_text
      assert_equal "s", Xml.inner_text(Xml.parse("<a><b>s</b></a>"))
      assert_equal "s", Xml.inner_text(Xml.parse("<a><b>s</b></a>"), "b")
    end

    def test_optional_inner_text
      assert_equal nil, Xml.optional_inner_text(Xml.parse("<a></a>"), "b")
      assert_equal 's', Xml.optional_inner_text(Xml.parse("<a><b>s</b></a>"), "b")
    end

    def test_select_return_element_match_path
      assert_equal "s", Xml.inner_text(Xml.select(Xml.parse("<a><b>s</b><b>t</b></a>"), 'a/b'))
    end

    def test_select_all_return_all_elements_match_path
      assert_equal ["s", "t"], Xml.select_all(Xml.parse("<a><b>s</b><b>t</b></a>"), 'a/b').map { |e| Xml.inner_text(e) }
    end

    def test_get_attribute_from_xml_element
      assert_equal "s", Xml.attr(Xml.select(Xml.parse('<a t="s"></a>'), 'a'), "t")
    end

    def test_get_children
      assert_equal ['s', 't', 'u'], Xml.children(Xml.select(Xml.parse(%{<a><s/> <t/> <u/> </a>}), 'a')).map { |e| Xml.tag_name(e)}
    end

    def test_get_raw_xml
      assert_equal_ignore_spaces "<b>s</b>", Xml.raw_xml(Xml.select(Xml.parse("<a><b>s</b></a>"), "a/b"))
    end

    private

    def assert_equal_ignore_spaces(expected, actual)
      assert_equal(expected.gsub(/\B/, ''), actual.gsub(/\B/, ''))
    end
  end
end
