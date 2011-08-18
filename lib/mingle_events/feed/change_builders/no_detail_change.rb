module MingleEvents
  module Feed
    module ChangeBuilders
      
      class NoDetailChange
        
        def initialize(category)
          @category = category
        end
        
        def build(element)
          {
            :category => @category, 
            :type => @category
          }         
        end
                          
      end      
    end
  end
end