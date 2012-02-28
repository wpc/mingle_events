module MingleEvents

  class ProjectCustomProperties

    def initialize(mingle_access, project_identifier)
      @mingle_access = mingle_access
      @project_identifier = project_identifier
    end

    def property_name_for_column(column_name)
      property_names_by_column_name[column_name]
    end

    private

    def property_names_by_column_name
      @property_names_by_column_name ||= lookup_property_names_by_column_name
    end

    def lookup_property_names_by_column_name
      as_document.select_all('/property_definitions/property_definition').inject({}) do |mapping, element|
        mapping[element.inner_text('column_name')] = element.inner_text('name')
        mapping
      end
    end

    def as_document
      @as_document ||= Xml.parse(@mingle_access.fetch_page("/api/v2/projects/#{@project_identifier}/property_definitions.xml"))
    end

  end

end
