class Basic::Permission < ActiveRecord::Base
  self.table_name = 'permissions'
  self.primary_key = 'permission_id'
end