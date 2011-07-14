module MingleEvents
  
  # Simple means of iterating over a project's events, hiding the mechanics
  # of pagination.
  class ProjectFeed
    
    def initialize(project_identifier, mingle_access, iteration_strategy = FromNow.new(project_identifier))
      @mingle_access = mingle_access
      @project_identifier = project_identifier
      @iteration_strategy = iteration_strategy
    end
  
    # All entries/events for a project, starting with the most recent. Be careful
    # not to take all events for a project with significant history without considering
    # the time this will require.
    def entries
      AllEntries.new(Page.new(@iteration_strategy.start_from, @mingle_access), 
                     @iteration_strategy)
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