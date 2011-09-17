module MingleEvents
  module Processors

    class Processor
    
      def process_events(events)
        events.map{|e| process(e)}
      end
      
      def process(event)
        raise "Subclass responsibility!"
      end
      
    end
    
  end
end
