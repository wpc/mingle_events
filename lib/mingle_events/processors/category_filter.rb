module MingleEvents
  module Processors
    
    # Removes events from the stream that do not match all of the specified categories
    class CategoryFilter < Filter
    
      def initialize(categories)
        @categories = categories
      end
      
      def match?(event)
        @categories.all?{|c| event.categories.include?(c)}
      end
        
    end
  end
end