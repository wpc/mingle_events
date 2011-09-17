module MingleEvents
  module Processors
    
    class HttpPostPublisher < Processor

      def initialize(url)
        @url = url
      end
      
      def process(event) 
        Net::HTTP.post_form(URI.parse(@url), {'event' => event.raw_xml}).body
      end
    
    end
  end
end
