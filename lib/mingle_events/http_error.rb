module MingleEvents
  
  class HttpError < StandardError
    
    attr_reader :response, :requested_location, :additional_context
    
    def initialize(response, requested_location, additional_context = nil)
      super(%{
        Unable to retrieve 200 response from URI: <#{requested_location}>!
        HTTP Code: #{response.code}
        Body: #{response.body}
        #{additional_context.nil? ? "" : additional_context}
      })
      @response = response
      @requested_location = requested_location
      @additional_context = additional_context
    end
    
    def not_found?
      # has to be a better way to do this!!
      response.class == Net::HTTPNotFound
    end
    
  end

end