module MingleEvents
  
  # Simple means of iterating over a project's events, hiding the mechanics
  # of pagination.
  class ProjectFeed
    
    def self.from_now(project_identifier, mingle_access)
      ProjectFeed.new(project_identifier, mingle_access)
    end
    
    def self.from_the_beginning(project_identifier, mingle_access)
      ProjectFeed.new(project_identifier, mingle_access, FromTheBeginning.new(project_identifier))
    end
    
    def initialize(project_identifier, mingle_access, iteration_strategy = FromNow.new(project_identifier))
      @mingle_access = mingle_access
      @project_identifier = project_identifier
      @iteration_strategy = iteration_strategy
    end
  
    # All entries/events for a project, starting with the most recent. 
    def entries
      AllEntries.new(Page.new(@iteration_strategy.start_from, @mingle_access), 
                     @iteration_strategy)
    end
    
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
  
    class AllEntries
    
      include Enumerable
    
      def initialize(first_page, iteration_strategy)
        @current_page = first_page
        @iteration_strategy = iteration_strategy
      end
    
      def each
        while (@current_page) 
          current_entries = @current_page.entries
          current_entries = current_entries.reverse if @iteration_strategy.reverse_page?
          current_entries.each{|e| yield e}
          @current_page = @current_page.send(@iteration_strategy.navigation_method)
        end
      end
    
      # TODO: what do i really want to do here?
      def <=>(other)
        return 0
      end
    
    end
  
  end 
end