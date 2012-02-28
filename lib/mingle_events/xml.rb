module MingleEvents
  module Xml

    class Element
      attr_reader :node
      def initialize(node)
        @node = node
      end

      def nil?
        @node.nil?
      end
      
      ["inner_text", "optional_inner_text", "select", "select_all", "attr", "children", "tag_name", "raw_xml", "attributes"].each do |method|
        self.class_eval(%{def #{method}(*args, &block)  Xml.#{method}(self, *args); end})
      end
      
      alias :[] :attr
    end

    
    module_function

    def parse(str)
      Element.new(Nokogiri::XML(str).remove_namespaces!)
    end

    def inner_text(element, xpath=nil)
      return element.node.inner_text unless xpath
      select(element, xpath).inner_text
    end

    def optional_inner_text(parent_element, xpath)
      element = select(parent_element, xpath)
      element.nil? ? nil : element.inner_text
    end

    def select(element, xpath)
      Element.new(element.node.at(xpath))
    end

    def select_all(element, xpath)
      element.node.search(xpath).map { |n| Element.new(n) }
    end

    def attr(element, attr_name)
      element.node[attr_name]
    end

    def children(element)
      element.node.children.select { |e| e.is_a?(Nokogiri::XML::Element) }.map { |n| Element.new(n) }
    end

    def tag_name(element)
      element.node.name
    end

    def raw_xml(element)
      element.node.to_s
    end

    def attributes(element)
      element.node.attribute_nodes.inject({}) do |memo, a|
        memo[a.name] = a.value
        memo
      end
    end
  end
end
