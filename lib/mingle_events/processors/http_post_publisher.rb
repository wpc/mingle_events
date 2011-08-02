module MingleEvents
  module Processors
    
    class HttpPostPublisher

      def initialize(url)
        @url = url
      end
      
      def process_events(events)
        events.map{|e| process_event(e)}
      end

      def process_event(event) 
        Net::HTTP.post_form(URI.parse(@url), {'event' => event.raw_xml}).body
      end
    
    end
  end
end
