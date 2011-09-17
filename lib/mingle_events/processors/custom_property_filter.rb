module MingleEvents
  module Processors
    
    # Filters events by a single custom property value. 
    # As events will not necessarily contain this data, 
    # this filter requires a lookup against Mingle to 
    # determine the type of the card that sourced the event. In the case
    # of the card's being deleted in the interim between the actual event
    # and this filtering, the event will be filtered as there is no means
    # to determine its type. Therefore, it's recommended to also
    # subscribe a 'CardDeleted' processor to the same project.    
    class CustomPropertyFilter < Filter
    
      def initialize(property_name, property_value, card_data)
        @property_name = property_name
        @property_value = property_value
        @card_data = card_data
      end
      
      def match?(event)
        event.card? && 
          @card_data.for_card_event(event) &&
          @property_value == @card_data.for_card_event(event)[:custom_properties][@property_name]
      end
    
    end
  end
end