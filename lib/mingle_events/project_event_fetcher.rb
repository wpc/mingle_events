module MingleEvents
  
  # fetch all unseen events and write them to disk for future processing
  class ProjectEventFetcher
    
    def initialize(project_identifier, mingle_access, state_dir)
      @project_identifier = project_identifier
      @mingle_access = mingle_access
      @state_dir = state_dir
    end
    
    def fetch_latest
      page = Page.new("/api/v2/projects/#{@project_identifier}/feeds/events.xml", @mingle_access)
      most_recent_new_entry = page.entries.first
      
      last_fetched_entry = load_last_fetched_entry
      fetched_previously_seen_event = false      
      next_entry = nil
      while !fetched_previously_seen_event && page
        page.entries.each do |entry|
                    
          if last_fetched_entry && entry.entry_id == last_fetched_entry.entry_id
            fetched_previously_seen_event = true
            break
          end
          
          write_entry_to_disk(entry, next_entry)
          next_entry = entry
        
        end
        page = page.next
      end
            
      update_current_state(most_recent_new_entry)
      
      file_for_entry(next_entry)
    end
    
    def file_for_entry(entry)
      return nil if entry.nil?
      
      entry_id_as_uri = URI.parse(entry.entry_id)
      relative_path_parts = "#{entry_id_as_uri.host}/#{entry_id_as_uri.path}".split('/')
      entry_id_int = relative_path_parts.last
      insertions = ["#{entry_id_int.to_i/16384}", "#{entry_id_int.to_i%16384}"]
      relative_path_parts = relative_path_parts[0..-2] + insertions + ["#{entry_id_int}.yml"]  
      File.join(@state_dir, 'events', *relative_path_parts)
    end
    
    def current_state_file
      File.expand_path(File.join(@state_dir, 'current_state.yml'))
    end
        
    private 
    
    def load_last_fetched_entry
      current_state = if File.exist?(current_state_file)
        YAML.load(File.new(current_state_file))
      else
        {:last_fetched_entry_info_file => nil}
      end
      last_fetched_entry = if current_state[:last_fetched_entry_info_file]
        last_fetched_entry_info = YAML.load(File.new(current_state[:last_fetched_entry_info_file]))
        Entry.new(Nokogiri::XML(last_fetched_entry_info[:entry_xml]).at('/entry'))
      else 
        nil
      end
    end
    
    def update_current_state(most_recent_new_entry)
      if most_recent_new_entry
        File.open(current_state_file, 'w') do |out|
          YAML.dump({:last_fetched_entry_info_file => file_for_entry(most_recent_new_entry)}, out)
        end
      end
    end
        
    def write_entry_to_disk(entry, next_entry)
      file = file_for_entry(entry)
      FileUtils.mkdir_p(File.dirname(file))
      file_content = {
        :entry_xml => entry.raw_xml,
        :next_entry_file_path => file_for_entry(next_entry)
      }
      File.open(file, 'w') do |out|
        YAML.dump(file_content, out)
      end
    end
    
  end
end