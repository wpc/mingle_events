module MingleEvents
  module Feed

    # Enumerable detail for each change specified in the entry's content section
    class Changes

      include Enumerable

      def initialize(changes_element)
        @changes_element = changes_element
      end

      def each
        (@changes ||= parse_changes).each{|c| yield c}
      end

      private

      def parse_changes
        changes = []
        @changes_element.select_all("change").map do |change_element|
          category = Category.for_mingle_term(change_element["type"])
          changes <<  Change.new(category).build(change_element)
        end
        changes
      end

      class Change

        def initialize(category)
          @category = category
        end

        def build(element)
          raw_hash_from_xml = element.to_hash

          raw_hash_from_xml[:change].merge({
            :category => @category,
            :type => @category
          })
        end
      end
    end
  end
end
