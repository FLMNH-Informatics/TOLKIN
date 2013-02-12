# == Schema Information
# Schema version: 20090423194502
#
# Table name: ip_logs
#
#  id            :integer         not null, primary key
#  failed_logins :integer
#  last_login    :datetime
#  ip_addr       :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class IpLog < ActiveRecord::Base
  #attr_protected :failed_logins, :ip_addr, :last_login
  #validates_format_of :ip_addr, :with=>/A[0-9][0-9][0-9].[0-9][0-9][0-9].[0-9][0-9][0-9]\Z
  def self.create_log(ip_addr)
    new_ip_log = IpLog.new
    new_ip_log.ip_addr = ip_addr
    #new_ip_log.last_login = Time.now
    new_ip_log.failed_logins = 0
    new_ip_log.save
    new_ip_log
  end
  def reset_falied_login
    self.last_login = Time.now
    self.failed_logins = 0
    self.save(false)
  end
  #def increment_falied_login
  #  failed_logins += 1
  #  save(false)
  #end
  def present_captcha?
    self.failed_logins > 4
  end
end
