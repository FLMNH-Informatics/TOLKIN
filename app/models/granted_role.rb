# == Schema Information
# Schema version: 20090423194502
#
# Table name: granted_roles
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  project_id   :integer
#  role_type_id :integer
#

class GrantedRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :role_type

  scope :for_projects, lambda { |projects| { :conditions => "project_id in (#{projects.collect{|p| p.id}.join(',')})" } }
end
