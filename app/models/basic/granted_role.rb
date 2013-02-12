class Basic::GrantedRole < ActiveRecord::Base

  self.table_name = 'granted_roles'
  belongs_to :user , :class_name => 'Basic::User'
  belongs_to :project , :class_name => 'Basic::Project'
end