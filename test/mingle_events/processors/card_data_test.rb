require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Processors
    
    #--
    # TODO: 
    # 1) add test to ensure lazy loading is cached and there
    # are not repeated calls to the server 
    # 2) better revision resource URIs in tests -- make tests more understandable
    class CardDataTest < Test::Unit::TestCase
  
      def test_load_basic_card_data
        event_1 = stub_event(1, 100, 11, ['card', 'comment-addition'])
        event_2 = stub_event(2, 101, 12, ['card', 'property-change'])
        event_3 = stub_event(3, nil, nil, ['revision-commit'])
        event_4 = stub_event(4, 103, 13, ['card', 'property-change'])
        events = [event_1, event_2, event_3, event_4]
    
        dummy_mingle_access = StubMingleAccess.new
        dummy_mingle_access.register_page_content(
          URI.escape('/api/v2/projects/atlas/cards/execute_mql.xml?mql=WHERE number IN (100,101,103)'),
          %{ 
          <?xml version="1.0" encoding="UTF-8"?> 
          <results type="array"> 
            <result>
              <number>100</number>
              <card_type_name>story</card_type_name>
              <version>11</version>
            </result>
            <result>
              <number>101</number>
              <card_type_name>bug</card_type_name>
              <version>12</version>
            </result>
            <result>
              <number>103</number>
              <card_type_name>story</card_type_name>
              <version>13</version>
            </result>
          </results>
          })
    
        card_data = CardData.new(dummy_mingle_access, 'atlas')
        card_data.process_events(events)
        
        assert_correct_basic_card_data_for_event(
          {:number => 100, :card_type_name => 'story', :version => 11},
          card_data, event_1)
        assert_correct_basic_card_data_for_event(
          {:number => 101, :card_type_name => 'bug', :version => 12},
          card_data, event_2)
        assert_correct_basic_card_data_for_event(
          {:number => 103, :card_type_name => 'story', :version => 13},
          card_data, event_4)
      end
            
      def test_load_custom_properties
        event_1 = stub_event(1, 100, 11, ['card', 'comment-addition'])
    
        dummy_mingle_access = StubMingleAccess.new
        dummy_mingle_access.register_page_content(
          URI.escape('/api/v2/projects/atlas/cards/execute_mql.xml?mql=WHERE number IN (100)'),
          %{ 
          <?xml version="1.0" encoding="UTF-8"?> 
          <results type="array"> 
            <result>
              <number>100</number>
              <card_type_name>story</card_type_name>
              <version>11</version>
              <cp_priority>Low</cp_priority>
              <cp_estimate>5</cp_estimate>
            </result>
          </results>
          })
          
        dummy_custom_properties = StubProjectCustomProperties.new({'cp_priority' => 'Foo', 'cp_estimate' => 'Bar'})
    
        card_data = CardData.new(dummy_mingle_access, 'atlas', dummy_custom_properties)
        card_data.process_events([event_1])
        
        assert_equal("Low", card_data.for_card_event(event_1)[:custom_properties]['Foo'])
        assert_equal("5", card_data.for_card_event(event_1)[:custom_properties]['Bar'])        
      end
      
      def test_load_basic_card_data_when_card_has_been_updated_beyond_the_specific_event
        event_1 = stub_event(1, 100, 11, ['card', 'comment-addition'])
        event_2 = stub_event(2, 101, 12, ['card', 'property-change'])
        event_3 = stub_event(3, nil, nil, ['revision-commit'])
        event_4 = stub_event(4, 103, 13, ['card', 'property-change'])
        events = [event_1, event_2, event_3, event_4]
    
        dummy_mingle_access = StubMingleAccess.new
        dummy_mingle_access.register_page_content(
          URI.escape('/api/v2/projects/atlas/cards/execute_mql.xml?mql=WHERE number IN (100,101,103)'),
          %{ 
          <?xml version="1.0" encoding="UTF-8"?> 
          <results type="array"> 
            <result>
              <number>100</number>
              <card_type_name>story</card_type_name>
              <version>11</version>
            </result>
            <result>
              <number>101</number>
              <card_type_name>bug</card_type_name>
              <version>14</version>
            </result>
            <result>
              <number>103</number>
              <card_type_name>story</card_type_name>
              <version>15</version>
            </result>
          </results>
          })
        dummy_mingle_access.register_page_content('http://example.com?version=12',%{
          <card>
            <number type="integer">101</number> 
            <card_type url="https://localhost:7071/api/v2/projects/atlas/card_types/24.xml"> 
              <name>issue</name> 
            </card_type> 
            <version type="integer">12</version>
            <cp_estimate>5</cp_estimate> 
          </card>
        })
        dummy_mingle_access.register_page_content('http://example.com?version=13',%{
          <card>
            <number type="integer">103</number> 
            <card_type url="https://localhost:7071/api/v2/projects/atlas/card_types/21.xml"> 
              <name>epic</name> 
            </card_type> 
            <version type="integer">13</version> 
          </card>
        })
    
        card_data = CardData.new(dummy_mingle_access, 'atlas')
        card_data.process_events(events)
        
        assert_correct_basic_card_data_for_event(
          {:number => 100, :card_type_name => 'story', :version => 11},
          card_data, event_1)
        assert_correct_basic_card_data_for_event(
          {:number => 101, :card_type_name => 'issue', :version => 12},
          card_data, event_2)
        assert_correct_basic_card_data_for_event(
          {:number => 103, :card_type_name => 'epic', :version => 13},
          card_data, event_4)
      end
      
      def test_load_custom_properties_when_card_has_been_updated_beyond_the_specific_event
        event_1 = stub_event(1, 100, 11, ['card', 'comment-addition'])
        events = [event_1]
    
        dummy_mingle_access = StubMingleAccess.new
        dummy_mingle_access.register_page_content(
          URI.escape('/api/v2/projects/atlas/cards/execute_mql.xml?mql=WHERE number IN (100)'),
          %{ 
          <?xml version="1.0" encoding="UTF-8"?> 
          <results type="array"> 
            <result>
              <number>100</number>
              <card_type_name>story</card_type_name>
              <version>12</version>
              <cp_priority>Low</cp_priority>
            </result>
          </results>
          }
        )
        dummy_mingle_access.register_page_content('http://example.com?version=11',
          %{
            <card>
              <number type="integer">101</number> 
              <card_type url="https://localhost:7071/api/v2/projects/atlas/card_types/24.xml"> 
                <name>issue</name> 
              </card_type> 
              <version type="integer">11</version>
              <properties type="array">
                <property type_description="Managed text list" hidden="false">
                  <name>Priority</name>
                  <value>High</value>
                </property>
              </properties>
            </card>
          }
        )
        
        dummy_custom_properties = StubProjectCustomProperties.new({'cp_priority' => 'Priority'})
    
        card_data = CardData.new(dummy_mingle_access, 'atlas', dummy_custom_properties)
        card_data.process_events(events)
        
        assert_equal 'High', card_data.for_card_event(event_1)[:custom_properties]['Priority']
      end
      
      def test_load_card_data_when_card_has_been_deleted_before_event_processing
        event_1 = stub_event(1, 100, 11, ['card', 'comment-addition'])
        events = [event_1]
    
        dummy_mingle_access = StubMingleAccess.new
        dummy_mingle_access.register_page_content(
          URI.escape('/api/v2/projects/atlas/cards/execute_mql.xml?mql=WHERE number IN (100)'),
          %{ 
          <?xml version="1.0" encoding="UTF-8"?> 
          <results type="array"> 
          </results>
          })
        dummy_mingle_access.register_page_not_found('http://example.com?version=11')
    
        card_data = CardData.new(dummy_mingle_access, 'atlas')
        card_data.process_events(events)
        
        assert_nil(card_data.for_card_event(event_1))
      end
            
      private 
  
      def stub_event(entry_id, card_number, version, categories)
        OpenStruct.new(
          :entry_id => entry_id, 
          :card_number => card_number, 
          :card? => !card_number.nil?,
          :version => version,
          :card_version_resource_uri => "http://example.com?version=#{version}",
          :categories => categories.map{|c| OpenStruct.new(:term => c)})
      end
      
      def assert_correct_basic_card_data_for_event(expected_data, actual_card_data, card_event)
        assert_equal(expected_data, actual_card_data.for_card_event(card_event).delete_if{|k,v| k == :custom_properties})
      end

    end
  end
end
