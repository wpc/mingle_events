module MingleEvents
  module Feed
    module ChangeBuilders
      
      class NameChange
        
        def build(element)
          {
            :category => Category::NAME_CHANGE, 
            :type => Category::NAME_CHANGE,
            :old_value => value(element.at_xpath("mingle:old_value")),
            :new_value => value(element.at_xpath("mingle:new_value"))
          }         
        end
        
        private
        
        def value(element)
          if element["nil"] == "true"
            nil
          else
            element.inner_text       
          end          
        end
                  
      end      
    end
  end
end