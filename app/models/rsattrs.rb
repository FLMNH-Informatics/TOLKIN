# record shared attributes
class Rsattrs < ActiveRecord::Base
  belongs_to :permission_set, primary_key: :permission_set_rtid,       foreign_key: :owner_permission_set_rtid
  has_many   :permissions,    primary_key: :owner_permission_set_rtid, foreign_key: :permission_set_rtid
end