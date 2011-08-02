module MingleEvents
  
  # Simple means of iterating over a project's events, hiding the mechanics of pagination.
  class ProjectFeed
        
    def initialize(project_identifier, mingle_access)
      @mingle_access = mingle_access
      @project_identifier = project_identifier
    end
    
    def most_recent_entry
      Page.new("/api/v2/projects/#{@project_identifier}/feeds/events.xml", @mingle_access).entries.first
    end
    
    # pass nil to start at beginning of time... need better signature here
    def entries_beyond(last_entry, last_page)  
      page = if last_entry.nil?
        Page.new("/api/v2/projects/#{@project_identifier}/feeds/events.xml?page=1", @mingle_access)
      else
        Page.new(last_page, @mingle_access)
      end
      
      AllEntriesBeyond.new(last_entry, page)
    end
    
    private 
        
    class AllEntriesBeyond
    
      include Enumerable
    
      def initialize(last_entry_id, page_containing_last_event)
        @last_entry_id = last_entry_id
        @page_containing_last_event = page_containing_last_event
      end
    
      def each
        last_entry_seen = @last_entry_id.nil?
        @page_containing_last_event.entries.reverse.each do |e|
          yield e if last_entry_seen
          if e.entry_id == @last_entry_id
            last_entry_seen = true
          end
        end
        
        @current_page = @page_containing_last_event.previous
        @page_containing_last_event = nil
        while (@current_page)
          @current_page.entries.reverse.each{|e| yield e}
          @current_page = @current_page.previous
        end
      end
    
      # TODO: what do i really want to do here?
      def <=>(other)
        return 0
      end
    
    end
  
  end 
end