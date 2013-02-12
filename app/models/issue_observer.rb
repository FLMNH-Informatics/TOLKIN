require 'net/http'
require 'net/https'
require 'uri'

class IssueObserver < ActiveRecord::Observer
  def after_create(issue)
    IssueMailer.deliver_issue_mail(issue)
  end
end
