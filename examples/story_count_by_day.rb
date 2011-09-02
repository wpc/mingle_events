# This example shows how to do some historical analysis a bit more complicated
# than what is demonstrated in story_count_by_day.rb, counting the number of
# stories at the end of each day.

require File.expand_path(File.join(File.dirname(__FILE__), '..','lib', 'mingle_events'))

class StoryCountProcessor
  
  def initialize
    @story_count_by_day = {}
    @current_day = nil
    @current_count = 0
    @stories = []
  end
  
  def process(event)    
    return unless event.card?
    
    if card_became_story(event)
      @current_count += 1
      @stories << event.card_number
    elsif card_no_longer_a_story(event)
      @current_count -= 1
      @stories.delete(event.card_number)
    elsif story_deleted(event)
      @current_count -= 1
      @stories.delete(event.card_number)
    end
    
    day = event.updated.strftime("%Y-%m-%d")
        
    if @current_day != day
      puts "Story total at end of #{@current_day}: #{@current_count}"
    end
    @current_day = day
    @story_count_by_day[@current_day] = @current_count
    
    # TODO: find missing days in @card_count_by_day and fill in the
    # previous day's value
  end
  
  def count_by_day
    @story_count_by_day
  end
  
  private
  
  def card_became_story(event)
    event.changes.find do |change|
      change[:type] == MingleEvents::Feed::Category::CARD_TYPE_CHANGE && 
        change[:new_value] &&
        change[:new_value][:card_type] &&
        change[:new_value][:card_type][:name].downcase == "story"
    end
  end
  
  def card_no_longer_a_story(event)
    event.changes.find do |change|
      change[:type] == MingleEvents::Feed::Category::CARD_TYPE_CHANGE && 
        change[:old_value] && 
        change[:old_value][:card_type] &&
        change[:old_value][:card_type][:name].downcase == "story"
    end
  end
  
  def story_deleted(event)
    event.changes.find do |change|
      change[:type] == MingleEvents::Feed::Category::CARD_DELETION && 
        @stories.include?(event.card_number)
    end
  end
    
end

# configuration (using ENV here as this is checked into github as an example)
base_url = ENV["MINGLE_BASE_URL"]
login = ENV["MINGLE_LOGIN"]
password = ENV["MINGLE_PASSWORD"]
project = ENV["MINGLE_PROJECT"]

mingle_access = MingleEvents::MingleBasicAuthAccess.new(base_url, login, password)
counter = StoryCountProcessor.new
# assumption is that events have been previously fetched. we just construct a
# ProjectEventFetcher in order to iterate over each event
event_fetcher = MingleEvents::ProjectEventFetcher.new(project, mingle_access)
event_fetcher.all_fetched_entries.each do |e| 
  begin
    counter.process(e)
  rescue 
    puts "Error processing #{e.raw_xml}"
    raise $!
  end
end

puts counter.count_by_day.inspect