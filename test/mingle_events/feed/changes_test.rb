require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Feed
    
    class ChangesTest < Test::Unit::TestCase
      
      def test_parse_multiple_changes
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
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
        entry = Entry.from_snippet(element_xml_text)
        
        # check that all the changes are built
        assert_equal 3, entry.changes.count        
        [Category::CARD_CREATION, Category::CARD_TYPE_CHANGE, Category::NAME_CHANGE].each do |change_type|
          assert entry.changes.find{|c| c[:category] == change_type}
        end
        
        # check that a change's detail is built
        card_type_change = entry.changes.find{|c| c[:category] == Category::CARD_TYPE_CHANGE}
        assert_equal('Defect', card_type_change[:new_value][:card_type][:name])
      end
            
      def test_parse_name_change_from_nil
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="name-change">
                  <old_value nil="true" />
                  <new_value>Basic email integration</new_value>
                </change
              </changes>
            </content>
          </entry>}
        entry = Entry.from_snippet(element_xml_text)
        
        change = entry.changes.first
        assert_equal(Category::NAME_CHANGE, change[:type])
        assert_equal(Category::NAME_CHANGE, change[:category])
        assert_nil change[:old_value]
        assert_equal("Basic email integration", change[:new_value])
      end
      
      def test_parse_name_change
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="name-change">
                  <old_value>Work with email</old_value>
                  <new_value>Basic email integration</new_value>
                </change>
              </changes>
            </content>
          </entry>}
        entry = Entry.from_snippet(element_xml_text)
        
        change = entry.changes.first        
        assert_equal(Category::NAME_CHANGE, change[:type])
        assert_equal(Category::NAME_CHANGE, change[:category])
        assert_equal("Work with email", change[:old_value])
        assert_equal("Basic email integration", change[:new_value])       
      end
      
      def test_parse_type_info_when_no_custom_builder_specified
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="card-creation"/>
              </changes>
            </content>
          </entry>}
        entry = Entry.from_snippet(element_xml_text)
        
        assert_equal(Category::CARD_CREATION, entry.changes.first[:type])
        assert_equal(Category::CARD_CREATION, entry.changes.first[:category])
      end
      
      def test_parse_card_type_change_from_nil
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
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
        entry = Entry.from_snippet(element_xml_text)
        
        change = entry.changes.first
        
        assert_equal(Category::CARD_TYPE_CHANGE, change[:type])
        assert_equal(Category::CARD_TYPE_CHANGE, change[:category])
        assert_nil change[:old_value]
        assert_equal("Defect", change[:new_value][:card_type][:name])
        assert_equal("https://mingle.example.com/api/v2/projects/atlas/card_types/27.xml", change[:new_value][:card_type][:url])
      end
      
      def test_parse_card_type_change
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="card-type-change">
                  <old_value>
                    <card_type url="https://mingle.example.com/api/v2/projects/atlas/card_types/30.xml">
                      <name>Story</name
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
        entry = Entry.from_snippet(element_xml_text)
        
        change = entry.changes.first
        assert_equal(Category::CARD_TYPE_CHANGE, change[:type])
        assert_equal(Category::CARD_TYPE_CHANGE, change[:category])
        assert_equal("Story", change[:old_value][:card_type][:name])
        assert_equal("https://mingle.example.com/api/v2/projects/atlas/card_types/30.xml", change[:old_value][:card_type][:url])
        assert_equal("Defect", change[:new_value][:card_type][:name])
        assert_equal("https://mingle.example.com/api/v2/projects/atlas/card_types/27.xml", change[:new_value][:card_type][:url])
      end
      
      def test_parse_card_type_change_to_deleted_type
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="card-type-change">
                  <old_value>
                    <card_type url="https://mingle.example.com/api/v2/projects/atlas/card_types/30.xml">
                      <name>Story</name>
                    </card_type>
                  </old_value>
                  <new_value>
                    <deleted_card_type>
                      <name>Card</name>
                    </deleted_card_type>
                  </new_value>
                </change>
              </changes>
            </content>
          </entry>}
        entry = Entry.from_snippet(element_xml_text)
                
        change = entry.changes.first
        assert_equal(Category::CARD_TYPE_CHANGE, change[:type])
        assert_equal(Category::CARD_TYPE_CHANGE, change[:category])
        assert_equal("Story", change[:old_value][:card_type][:name])
        assert_equal("https://mingle.example.com/api/v2/projects/atlas/card_types/30.xml", change[:old_value][:card_type][:url])
        assert_equal("Card", change[:new_value][:deleted_card_type][:name])
        assert_equal(nil, change[:new_value][:deleted_card_type][:url])
      end     
      
      def test_parse_card_property_change
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="property-change">
                  <property_definition 
                      url="http://mingle.example.com/api/v2/projects/atlas/property_definitions/10418.xml">
                    <name>Priority</name>
                    <position nil="true"></position>
                    <data_type>string</data_type>
                    <is_numeric type="boolean">false</is_numeric>
                  </property_definition>
                  <old_value>nice</old_value>
                  <new_value>must</new_value>
                </change>
              </changes>
            </content>
          </entry>}
        entry = Entry.from_snippet(element_xml_text)
                
        change = entry.changes.first
        assert_equal(Category::PROPERTY_CHANGE, change[:type])
        assert_equal(Category::PROPERTY_CHANGE, change[:category])
        assert_equal(
          "http://mingle.example.com/api/v2/projects/atlas/property_definitions/10418.xml", 
          change[:property_definition][:url]
        )
        assert_equal("Priority", change[:property_definition][:name])
        assert_equal("nice", change[:old_value])
        assert_equal("must", change[:new_value])
      end  
      
      def test_parse_card_property_change_from_nil
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="property-change">
                  <property_definition 
                      url="http://mingle.example.com/api/v2/projects/atlas/property_definitions/10418.xml">
                    <name>Priority</name>
                    <position nil="true"></position>
                    <data_type>string</data_type>
                    <is_numeric type="boolean">false</is_numeric>
                  </property_definition>
                  <old_value nil="true"></old_value>
                  <new_value>must</new_value>
                </change>
              </changes>
            </content>
          </entry>}
        entry = Entry.from_snippet(element_xml_text)
                
        change = entry.changes.first
        assert_nil(change[:old_value])
        assert_equal("must", change[:new_value])
      end   
      
      def test_parse_card_property_change_to_nil
        element_xml_text = %{
          <entry xmlns="http://www.w3.org/2005/Atom">
            <content type="application/vnd.mingle+xml">
              <changes xmlns="http://www.thoughtworks-studios.com/ns/mingle">
                <change type="property-change">
                  <property_definition 
                      url="http://mingle.example.com/api/v2/projects/atlas/property_definitions/10418.xml">
                    <name>Priority</name>
                    <position nil="true"></position>
                    <data_type>string</data_type>
                    <is_numeric type="boolean">false</is_numeric>
                  </property_definition>
                  <old_value>nice</old_value>
                  <new_value nil="true"></new_value>
                </change>
              </changes>
            </content>
          </entry>}
        entry = Entry.from_snippet(element_xml_text)
                
        change = entry.changes.first
        assert_equal("nice", change[:old_value])
        assert_nil(change[:new_value])
      end  
      
    end        
  end
end
