require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Processors
    
    class CustomPropertyFilterTest < Test::Unit::TestCase
  
      def test_filters_events_on_custom_property
        event_1 = stub_event(true)
        event_2 = stub_event(false)
        event_3 = stub_event(true)
        event_4 = stub_event(true)
        event_5 = stub_event(true)
        
        card_data = {
          event_1 => {:custom_properties => {'Priority' => 'High'}},
          event_3 => {:custom_properties => {'Priority' => 'Low'}},
          event_4 => {:custom_properties => {'Priority' => 'High'}},
          event_5 => {:custom_properties => {'Severity' => 'High'}}
        }
        def card_data.for_card_event(card_event)
          self[card_event]
        end
        
        filter = CustomPropertyFilter.new('Priority', 'High', card_data)
        filtered_events = filter.process_events([event_1, event_2, event_3, event_4, event_5])
        assert_equal([event_1, event_4], filtered_events)
      end
      
      def test_drops_events_for_deleted_cards
        event_1 = stub_event(true)
        
        card_data = {}
        def card_data.for_card_event(card_event)
          self[card_event]
        end
        
        filter = CustomPropertyFilter.new('Priority', 'High', card_data)
        filtered_events = filter.process_events([event_1])
        assert_equal([], filtered_events)
      end
      
      private
      
      def stub_event(is_card)
        OpenStruct.new(:card? => is_card)
      end
      
    end
  end
end
