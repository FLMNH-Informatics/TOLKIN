class Basic::PermissionSet < ActiveRecord::Base
  self.table_name = 'permission_sets'
  self.primary_key= 'permission_set_id'
end