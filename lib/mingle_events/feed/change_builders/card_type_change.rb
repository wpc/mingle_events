module MingleEvents
  module Feed
    module ChangeBuilders
      
      class CardTypeChange
        
        def build(element)
          {
            :category => Category::CARD_TYPE_CHANGE, 
            :type => Category::CARD_TYPE_CHANGE,
            :old_value => build_card_type(element.at_xpath("mingle:old_value")),
            :new_value => build_card_type(element.at_xpath("mingle:new_value"))
          }         
        end
        
        private
        
        def build_card_type(element)
          if element["nil"] == "true"
            nil
          else
            {
              :url => element.at_xpath("mingle:card_type")["url"],
              :name => element.at_xpath("mingle:card_type/mingle:name").inner_text
            }       
          end          
        end
                  
      end      
    end
  end
end