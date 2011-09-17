require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Processors
    class FilterTest < Test::Unit::TestCase  
      
      def test_returns_events_that_match
        assert_equal([0,2,4], MatchEvenFilter.new.process_events([0,1,2,3,4,5]))
      end
      
      class MatchEvenFilter < Filter
        def match?(event)
          event % 2 == 0
        end
      end

    end
  end
end
