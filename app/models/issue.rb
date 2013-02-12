# == Schema Information
# Schema version: 20090423194502
#
# Table name: issues
#
#  id                   :integer         not null, primary key
#  description          :string(255)
#  subject              :string(255)
#  external_status_code :string(255)
#  user_id              :integer
#  status               :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  email                :string(255)
#

class Issue < ActiveRecord::Base
  attr_accessible :description, :subject, :email
  validates_presence_of :user_id, :description
  validates_format_of :email, :with =>  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Please enter a proper email.", :allow_nil => true, :allow_blank => true
  belongs_to :user
end
