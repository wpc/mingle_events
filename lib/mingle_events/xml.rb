module MingleEvents
  module Xml
    module_function

    def parse(str)
      Nokogiri::XML(str).remove_namespaces!
    end

    def inner_text(element, xpath=nil)
      return element.inner_text unless xpath
      select(element, xpath).inner_text
    end

    def optional_inner_text(parent_element, xpath)
      element = select(parent_element, xpath)
      element.nil? ? nil : element.inner_text
    end

    def select(element, xpath)
      element.at(xpath)
    end

    def select_all(element, xpath)
      element.search(xpath)
    end

    def attr(element, attr_name)
      element[attr_name]
    end

    def children(element)
      element.children.select { |e| e.is_a?(Nokogiri::XML::Element) }
    end

    def tag_name(element)
      element.name
    end

    def raw_xml(element)
      element.to_s
    end
  end
end
