require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module MingleEvents
  
  class ProjectCustomPropertiesTest < Test::Unit::TestCase
  
    def test_can_lookup_property_name_by_column_name
      property_definitions_xml = %{
        <?xml version="1.0" encoding="UTF-8"?> 
        <property_definitions type="array"> 
          <property_definition> 
            <name>Account</name> 
            <data_type>string</data_type> 
            <is_numeric type="boolean">false</is_numeric> 
            <column_name>cp_account</column_name> 
          </property_definition> 
          <property_definition> 
            <name>Account ID</name> 
            <data_type>string</data_type> 
            <is_numeric type="boolean">false</is_numeric> 
            <column_name>cp_account_id</column_name> 
          </property_definition> 
        </property_definitions>       
      }
      
      dummy_mingle_access = StubMingleAccess.new
      dummy_mingle_access.register_page_content(
        URI.escape('/api/v2/projects/atlas/property_definitions.xml'),
        property_definitions_xml
      )
      
      project_custom_properties = ProjectCustomProperties.new(dummy_mingle_access, "atlas")
      assert_equal("Account ID", project_custom_properties.property_name_for_column("cp_account_id"))
      
    end
    
  end
  
end
