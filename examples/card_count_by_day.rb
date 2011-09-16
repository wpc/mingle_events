# This example shows how to do a very simple historical analysis 
# by playing back a project's events.  Here we take a look at the
# total count of cards at the end of each day.

require File.expand_path(File.join(File.dirname(__FILE__), '..','lib', 'mingle_events'))

class CardCountProcessor
  
  def initialize
    @card_count_by_day = {}
    @current_day = nil
    @current_count = 0
    @events_processed = 0
  end
  
  def process(event)
    @events_processed += 1
    
    if (event.categories.include?(MingleEvents::Feed::Category::CARD_CREATION))
      @current_count += 1
    elsif (event.categories.include?(MingleEvents::Feed::Category::CARD_DELETION))
      @current_count -= 1
    end
    
    day = event.updated.strftime("%Y-%m-%d")
        
    puts "Done processing #{@current_day}, card count: #{@current_count}, total events processed: #{@events_processed}" if @current_day != day
    @current_day = day
    @card_count_by_day[@current_day] = @current_count
    
    # TODO: find missing days in @card_count_by_day and fill in the
    # previous day's value
  end
  
  def count_by_day
    @card_count_by_day
  end
    
end

# configuration (using ENV here as this is checked into github as an example)
base_url = ENV["MINGLE_BASE_URL"]
login = ENV["MINGLE_LOGIN"]
password = ENV["MINGLE_PASSWORD"]
project = ENV["MINGLE_PROJECT"]

mingle_access = MingleEvents::MingleBasicAuthAccess.new(base_url, login, password)
card_counter = CardCountProcessor.new
# assumption is that events have been previously fetched. we just construct a
# ProjectEventFetcher in order to iterate over each event
event_fetcher = MingleEvents::ProjectEventFetcher.new(project, mingle_access)
event_fetcher.all_fetched_entries.each{|e| card_counter.process(e)}

puts card_counter.count_by_day.sort_by{|k,v| k}.inspect