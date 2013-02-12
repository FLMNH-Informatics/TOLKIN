class RoleType < ActiveRecord::Base
  has_many :granted_roles
end
