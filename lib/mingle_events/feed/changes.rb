require File.expand_path(File.join(File.dirname(__FILE__), 'change_builders', 'card_type_change')) 
require File.expand_path(File.join(File.dirname(__FILE__), 'change_builders', 'no_detail_change')) 
require File.expand_path(File.join(File.dirname(__FILE__), 'change_builders', 'name_change')) 

module MingleEvents  
  module Feed
    
    # Enumerable detail for each change specified in the entry's content section 
    class Changes
      
      include Enumerable
      
      BUILDERS = {
        Category::CARD_CREATION => ChangeBuilders::NoDetailChange.new(Category::CARD_CREATION),
        Category::CARD_DELETION => ChangeBuilders::NoDetailChange.new(Category::CARD_DELETION),
        Category::CARD_TYPE_CHANGE => ChangeBuilders::CardTypeChange.new,
        Category::NAME_CHANGE => ChangeBuilders::NameChange.new
      }
      
      def initialize(changes_element)
        @changes_element = changes_element
      end
      
      def each        
        (@changes ||= parse_changes).each{|c| yield c}
      end
      
      private
      
      def parse_changes
        changes = []
        @changes_element.xpath("mingle:change").map do |change_element|
          category = Category.for_mingle_term(change_element["type"])
          changes <<  BUILDERS[category].build(change_element)
        end
        changes
      end

    end    
  end
end
