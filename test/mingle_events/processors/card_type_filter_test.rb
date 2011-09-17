require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Processors
    
    class CardTypeFilterTest < Test::Unit::TestCase
      
      def setup      
        @story_event = stub_event(true)
        @page_event = stub_event(false)
        @bug_event = stub_event(true)
        @issue_event = stub_event(true)
        
        @card_data = {
          @story_event => {:card_type_name => 'story'},
          @bug_event => {:card_type_name => 'bug'},
          @issue_event => {:card_type_name => 'issue'}
        }
        def @card_data.for_card_event(card_event)
          self[card_event]
        end
        
        @filter = CardTypeFilter.new(['story', 'issue'], @card_data)
      end
      
      def test_does_not_match_non_card_events
        assert !@filter.match?(@page_event)
      end
  
      def test_match_on_card_type
        assert @filter.match?(@story_event)
        assert @filter.match?(@issue_event)
        assert !@filter.match?(@bug_event)
      end
      
      def test_does_not_match_deleted_cards
        @card_data[@story_event] = nil
        assert !@filter.match?(@story_event)
      end
      
      private
      
      def stub_event(is_card)
        OpenStruct.new(:card? => is_card)
      end
      
    end
  end
end
