module MingleEvents
  module Processors

    class Filter
    
      def process_events(events)
        events.select{|e| match?(e)}
      end
      
      def match?(event)
        raise "Subclass responsibility!"
      end
      
    end
    
  end
end
