module MingleEvents
  module Processors
    
    # Writes each event in stream to stdout, mostly for demonstration purposes
    class PutsPublisher
      
      def process_events(events)
        events.map{|e| process_event(e)}
      end

      def process_event(event) 
        puts "Processing event #{event}"
      end
    
    end
  end
end
