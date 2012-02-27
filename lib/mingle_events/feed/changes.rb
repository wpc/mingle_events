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
        @changes_element.search("change").map do |change_element|
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
          element_to_hash(element)

          raw_hash_from_xml = element_to_hash(element)

          raw_hash_from_xml[:change].merge({
            :category => @category,
            :type => @category
          })
        end

        private

        def element_to_hash(element, hash = {})
          hash_for_element = (hash[element.name.to_sym] ||= {})

          element.attribute_nodes.each do |a|
            hash_for_element[a.name.to_sym] = a.value
          end

          Xml.children(element).each do |child|
            if Xml.children(child).any?
              element_to_hash(child, hash_for_element)
            else
              hash_for_element[Xml.tag_name(child).to_sym] = if Xml.attr(child, "nil") && Xml.attr(child, "nil") == "true"
                                                           nil
                                                         else
                                                           Xml.inner_text(child)
                                                         end
            end
          end

          hash
        end

      end


    end
  end
end
