module MingleEvents
  
  class FromTheBeginning
    
    def initialize(project_identifier)
      @project_identifier = project_identifier
    end
    
    def navigation_method
      :previous
    end
    
    def start_from
      "/api/v2/projects/#{@project_identifier}/feeds/events.xml?page=1"      
    end
    
    def reverse_page?
      true
    end    
    
  end
  
end