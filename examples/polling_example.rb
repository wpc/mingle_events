# This example shows a poll for all new events in a project.
# The events are filtered to only those with comment additions
# and then POSTed to another service (here just a dummy service listening locally)

require 'lib/mingle_events'

def rmdir_on_clean(dir)
  FileUtils.rm_rf(File.expand_path(dir)) if ENV['CLEAN'] == 'true'
end

rmdir_on_clean("~/.mingle_events/localhost")

# configuration (using ENV here as this is checked into github as an example)
base_url = ENV["MINGLE_BASE_URL"]
login = ENV["MINGLE_LOGIN"]
password = ENV["MINGLE_PASSWORD"]
project = ENV["MINGLE_PROJECT"]
mingle_access = MingleEvents::MingleBasicAuthAccess.new(base_url, login, password)
  
# assemble processing pipeline
post_comments_to_another_service = MingleEvents::Processors::Pipeline.new([
  MingleEvents::Processors::CategoryFilter.new([MingleEvents::Feed::Category::COMMENT_ADDITION]),
  MingleEvents::Processors::HttpPostPublisher.new('http://localhost:4567/')
])
      
# poll once
MingleEvents::Poller.new(mingle_access, {project => [post_comments_to_another_service]}).run_once  
