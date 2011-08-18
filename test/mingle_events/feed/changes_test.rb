require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Feed
    
    class ChangesTest < Test::Unit::TestCase
      
      def test_parse_multiple_changes
        element_xml_text = %{
          <entry xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="card-creation"/>
                <change type="card-type-change">
                  <old_value nil="true"></old_value>
                  <new_value>
                    <card_type url="https://mingle.example.com/api/v2/projects/atlas/card_types/27.xml">
                      <name>Defect</name>
                    </card_type>
                  </new_value>
                </change>
                <change type="name-change">
                  <old_value nil="true"></old_value>
                  <new_value>A New Card</new_value>
                </change>
              </changes>
            </content>
          </entry>}
        element = Nokogiri::XML(element_xml_text)
        entry = Entry.new(element)
        
        # check that all the changes are built
        assert_equal 3, entry.changes.count        
        [Category::CARD_CREATION, Category::CARD_TYPE_CHANGE, Category::NAME_CHANGE].each do |change_type|
          assert entry.changes.find{|c| c[:category] == change_type}
        end
        
        # check that a change's detail is built
        card_type_change = entry.changes.find{|c| c[:category] == Category::CARD_TYPE_CHANGE}
        assert_equal('Defect', card_type_change[:new_value][:name])
      end
            
      def test_parse_name_change_from_nil
        element_xml_text = %{
          <entry xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="name-change">
                  <old_value nil="true" />
                  <new_value>Basic email integration</new_value>
                </change
              </changes>
            </content>
          </entry>}
        element = Nokogiri::XML(element_xml_text)
        entry = Entry.new(element)
        
        change = entry.changes.first
        assert_equal(Category::NAME_CHANGE, change[:type])
        assert_equal(Category::NAME_CHANGE, change[:category])
        assert_nil change[:old_value]
        assert_equal("Basic email integration", change[:new_value])
      end
      
      def test_parse_name_change
        element_xml_text = %{
          <entry xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="name-change">
                  <old_value>Work with email</old_value>
                  <new_value>Basic email integration</new_value>
                </change
              </changes>
            </content>
          </entry>}
        element = Nokogiri::XML(element_xml_text)
        entry = Entry.new(element)
        
        change = entry.changes.first
        assert_equal(Category::NAME_CHANGE, change[:type])
        assert_equal(Category::NAME_CHANGE, change[:category])
        assert_equal("Work with email", change[:old_value])
        assert_equal("Basic email integration", change[:new_value])       
      end
      
      def test_parse_type_info_when_no_custom_builder_specified
        element_xml_text = %{
          <entry xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="card-creation"/>
              </changes>
            </content>
          </entry>}
        element = Nokogiri::XML(element_xml_text)
        entry = Entry.new(element)
        
        assert_equal(Category::CARD_CREATION, entry.changes.first[:type])
        assert_equal(Category::CARD_CREATION, entry.changes.first[:category])
      end
      
      def test_parse_card_type_change_from_nil
        element_xml_text = %{
          <entry xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="card-type-change">
                  <old_value nil="true"></old_value>
                  <new_value>
                    <card_type url="https://mingle.example.com/api/v2/projects/atlas/card_types/27.xml">
                      <name>Defect</name>
                    </card_type>
                  </new_value>
                </change>
              </changes>
            </content>
          </entry>}
        element = Nokogiri::XML(element_xml_text)
        entry = Entry.new(element)
        
        change = entry.changes.first
        assert_equal(Category::CARD_TYPE_CHANGE, change[:type])
        assert_equal(Category::CARD_TYPE_CHANGE, change[:category])
        assert_nil change[:old_value]
        assert_equal("Defect", change[:new_value][:name])
        assert_equal("https://mingle.example.com/api/v2/projects/atlas/card_types/27.xml", change[:new_value][:url])
      end
      
      def test_parse_card_type_change
        element_xml_text = %{
          <entry xmlns:mingle="http://www.thoughtworks-studios.com/ns/mingle">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="card-type-change">
                  <old_value>
                    <card_type url="https://mingle.example.com/api/v2/projects/atlas/card_types/30.xml">
                      <name>Story</name>
                    </card_type>
                  </old_value>
                  <new_value>
                    <card_type url="https://mingle.example.com/api/v2/projects/atlas/card_types/27.xml">
                      <name>Defect</name>
                    </card_type>
                  </new_value>
                </change>
              </changes>
            </content>
          </entry>}
        element = Nokogiri::XML(element_xml_text)
        entry = Entry.new(element)
        
        change = entry.changes.first
        assert_equal(Category::CARD_TYPE_CHANGE, change[:type])
        assert_equal(Category::CARD_TYPE_CHANGE, change[:category])
        assert_equal("Story", change[:old_value][:name])
        assert_equal("https://mingle.example.com/api/v2/projects/atlas/card_types/30.xml", change[:old_value][:url])
        assert_equal("Defect", change[:new_value][:name])
        assert_equal("https://mingle.example.com/api/v2/projects/atlas/card_types/27.xml", change[:new_value][:url])
      end
      
    end        
  end
end
