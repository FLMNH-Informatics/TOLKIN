class Basic::Role < ActiveRecord::Base
    self.table_name = 'roles'
    self.primary_key = 'role_id'

    belongs_to :user, :class_name =>  'Basic::User'
end