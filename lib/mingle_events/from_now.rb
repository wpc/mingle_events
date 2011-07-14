module MingleEvents
  
  class FromNow
    
    def initialize(project_identifier)
      @project_identifier = project_identifier
    end
    
    def navigation_method
      :next
    end
    
    def start_from
      "/api/v2/projects/#{@project_identifier}/feeds/events.xml"      
    end
    
    def reverse_page?
      false
    end
    
  end
  
end