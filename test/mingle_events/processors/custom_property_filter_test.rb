require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Processors
    
    class CustomPropertyFilterTest < Test::Unit::TestCase
  
      def setup
        @high_priority_event = stub_event(true)
        @page_event = stub_event(false)
        @low_priority_event = stub_event(true)
        @high_severity_event = stub_event(true)
        
        @card_data = {
          @high_priority_event => {:custom_properties => {'Priority' => 'High'}},
          @low_priority_event => {:custom_properties => {'Priority' => 'Low'}},
          @high_severity_event => {:custom_properties => {'Severity' => 'High'}}
        }
        def @card_data.for_card_event(card_event)
          self[card_event]
        end
        
        @filter = CustomPropertyFilter.new('Priority', 'High', @card_data)
      end

      def test_match_on_property_value
        assert @filter.match?(@high_priority_event)
        assert !@filter.match?(@low_priority_event)
        assert !@filter.match?(@high_severity_event)
      end
      
      def test_does_not_match_delete_card
        @card_data[@high_priority_event] = nil
        assert !@filter.match?(@high_priority_event)
      end
              
      private
      
      def stub_event(is_card)
        OpenStruct.new(:card? => is_card)
      end
      
    end
  end
end
