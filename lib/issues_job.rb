require 'net/http'
require 'net/https'
require 'uri'

module Net
  class HTTPS < HTTP
    def self.post_form(url, params)
      request = Post.new(url.path)
      request.form_data = params
      request.basic_auth REDMINE_CONFIG['username'], REDMINE_CONFIG['password']# if url.user
      http = new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      http.start {|h| h.request(request) }
    end
  end
end

module IssuesJob
  class IssueJob < Struct.new(:issue_id,:subject, :description)
    def perform
      send_hook({'subject'=>subject, 'description'=>description})
    end    
    
    protected
    def send_hook(data)
      uri = URI.parse(REDMINE_CONFIG['url'])
      email = IssueMailer.create_issue_mail(data['subject'], {'description' => data['description']})
      logger.info "Posting to #{uri}..."
      response = Net::HTTPS.post_form(uri, {'email' => email, 'key' => REDMINE_CONFIG['key'],
      'issue[tracker]'=> REDMINE_CONFIG['tracker'],
      'issue[status]'=> REDMINE_CONFIG['status'],
      'issue[priority]'=> REDMINE_CONFIG['priority'],
      'issue[project]'=> REDMINE_CONFIG['project'],
      'issue[description]'=> REDMINE_CONFIG['description']});
       
      logger.info "Response received: #{response.code}"
      logger.info "Response received: #{response.inspect}"
      
      logger.info "Request was denied by your Redmine server. " + 
         "Please, make sure that 'WS for incoming emails' is enabled in application settings and that you provided the correct API key." if response.code == '403'
      if response.code == '201' || response.code =~ /\A2[0-9][0-9]\z/
        Issue.find(issue_id).update_attribute('external_status_code', response.code)
      else
        raise "Issue not created. Response code :#{response.code}"
      end
    end
    
    def logger
      RAILS_DEFAULT_LOGGER
    end
  end
end
