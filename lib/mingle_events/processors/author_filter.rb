module MingleEvents
  module Processors
    
    # Removes all events from stream not triggered by the specified author
    class AuthorFilter < Filter
    
      def initialize(spec, mingle_access, project_identifier)
        unless spec.size == 1
          raise "Author spec must contain 1 and only 1 piece of criteria (the only legal criteria are each unique identifiers in and of themselves so multiple criteria is not needed.)"
        end
        
        @author_spec = AuthorSpec.new(spec, mingle_access, project_identifier)
      end
    
      def match?(event)
        @author_spec.event_triggered_by?(event)
      end
          
      class AuthorSpec
        
        def initialize(spec, mingle_access, project_identifier)
          @spec = spec
          @mingle_access = mingle_access
          @project_identifier = project_identifier
        end
        
        def event_triggered_by?(event)
          event.author.uri == author_uri
        end
        
        private 
        
        def author_uri
          lookup_author_uri
        end
        
        def lookup_author_uri
          team_resource = "/api/v2/projects/#{@project_identifier}/team.xml"
          @raw_xml ||= @mingle_access.fetch_page(URIParser.escape(team_resource))
          @doc ||= Xml.parse(@raw_xml)

          users = Xml.select_all(@doc, '/projects_members/projects_member/user').map do |user|
            {
              :url => Xml.attr(user, 'url'),
              :login => Xml.inner_text(user, 'login'),
              :email => Xml.inner_text(user, 'email')
            }
          end
          
          spec_user = users.find do |user|
            # is this too hacky?
            user.merge(@spec) == user
          end
          
          spec_user.nil? ? nil : spec_user[:url]
        end
        
      end
    
    end
  end
end
