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
          raw_hash_from_xml = element_to_hash(element)

          raw_hash_from_xml[:change].merge({
            :category => @category,
            :type => @category
          })
        end

        private

        def element_to_hash(element, hash = {})
          hash_for_element = (hash[element.tag_name.to_sym] ||= {})

          element.attributes.each do |name, value|
            hash_for_element[name.to_sym] = value
          end

          element.children.each do |child|
            if child.children.any?
              element_to_hash(child, hash_for_element)
            else
              hash_for_element[child.tag_name.to_sym] = if child.attr("nil") && child.attr("nil") == "true"
                                                           nil
                                                         else
                                                           child.inner_text
                                                         end
            end
          end

          hash
        end

      end


    end
  end
end
