require 'ostruct'

module MingleEvents
    
  # For a given project, polls for previously unseen entrys and broadcasts these entrys
  # to a list of processors, all interested in the project's entrys.
  class ProjectEventBroadcaster
            
    # legal strategies for init_strategy are :from_now and :from_beginning_of_time
    def initialize(mingle_feed, entry_processors, state_file, init_strategy = :from_now, logger = Logger.new(STDOUT))
      @mingle_feed = mingle_feed
      @entry_processors = entry_processors
      @state_file = state_file
      @init_strategy = init_strategy
      @logger = logger
    end  

    # Perform the polling for new events and subsequent broadasting to interested processors
    def run_once
      if !initialized?
        write_initial_state
      end

      process_latest_events
    end

    private
    
    def process_latest_events
      @mingle_feed.entries_beyond(last_entry, last_page).each do |entry|
        @entry_processors.each do |processor|
          begin
            processor.process_events([entry])
            update_state(entry)
          rescue StandardError => e
            log_processing_error(e, entry, processor)
            return
          end
        end
      end
    end
    
    def log_processing_error(error, entry, processor)
      @logger.error(%{

Unable to complete entry processing for event #{entry} with processor #{processor}! 
All event processing will stop. The next run will begin processing at this same event.

Root Cause: #{error}
Trace: #{error.backtrace.join("\n")}
entry: #{entry}
      })
    end
            
    def write_initial_state
      if @init_strategy == :from_now
        update_state(@mingle_feed.most_recent_entry || event_zero_state)
      else
        update_state(event_zero_state)
      end
    end
    
    def event_zero_state
      OpenStruct.new(:last_entry => nil, :last_page => nil)
    end
    
    def last_entry
      read_state[:last_entry]
    end
    
    def last_page
      read_state[:last_page]
    end
    
    def initialized?
      File.exist?(@state_file)
    end
        
    def read_state
      @state ||= YAML.load(File.new(@state_file))
    end

    def update_state(last_entry)      
      FileUtils.mkdir_p(File.dirname(@state_file))
      File.open(@state_file, 'w') do |out|
        YAML.dump({
          :last_entry => last_entry.entry_id,
          :last_page => last_entry.page_url}, out)
      end
    end

  end
end