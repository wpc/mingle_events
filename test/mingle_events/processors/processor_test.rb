require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Processors
    class ProcessorTest < Test::Unit::TestCase  
      
      def test_returns_events_that_match
        assert_equal([0,2,4], DoubleProcessor.new.process_events([0,1,2]))
      end
      
      class DoubleProcessor < Processor
        def process(event)
          event * 2
        end
      end

    end
  end
end
