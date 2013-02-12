class Basic::RoleMemberUser < ActiveRecord::Base
   self.table_name = 'role_member_users'
   self.primary_key = 'statement_id'
end