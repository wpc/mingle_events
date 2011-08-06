module MingleEvents
  class Poller
    
    # Manages a full sweep of event processing across each processing pipeline
    # configured for specified mingle projects. processors_by_project_identifier should
    # be a hash where the keys are mingle project identifiers and the values are
    # lists of event processors.
    def initialize(mingle_access, processors_by_project_identifier)
      @mingle_access = mingle_access
      @processors_by_project_identifier = processors_by_project_identifier
    end

    # Run a single poll for each project configured with processor(s) and 
    # broadcast each event to each processor.
    def run_once(options={})
      MingleEvents.log.info("MingleEvents::Poller about to poll once...")
      @processors_by_project_identifier.each do |project_identifier, processors|
        fetcher = ProjectEventFetcher.new(project_identifier, @mingle_access)
        fetcher.reset if options[:clean]
        info_file_for_new_event = fetcher.fetch_latest 
        while info_file_for_new_event  
          entry_info = YAML.load(File.new(info_file_for_new_event))
          entry = Feed::Entry.new(Nokogiri::XML(entry_info[:entry_xml]).at('/entry'))
          MingleEvents.log.info("About to process event #{entry.entry_id}...")
          processors.each{|p| p.process_events([entry])}
          info_file_for_new_event = entry_info[:next_entry_file_path]
        end
      end
    end
    
  end
end