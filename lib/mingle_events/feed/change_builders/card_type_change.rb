module MingleEvents
  module Feed
    module ChangeBuilders
      
      class CardTypeChange
        
        def build(element)
          {
            :category => Category::CARD_TYPE_CHANGE, 
            :type => Category::CARD_TYPE_CHANGE,
            :old_value => build_card_type(element.at("old_value")),
            :new_value => build_card_type(element.at("new_value"))
          }         
        end
        
        private
        
        def build_card_type(element)
          if element["nil"] == "true"
            nil
          else
            if element.at("card_type")
              {
                :url => element.at("card_type")["url"],
                :name => element.at("card_type/name").inner_text
              }
            else
              {
                :deleted? => true,
                :name => element.at("deleted_card_type/name").inner_text
              }
            end
          end          
        end
                  
      end      
    end
  end
end