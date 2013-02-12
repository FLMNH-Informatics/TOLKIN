class RoleMemberUser < Record
  belongs_to :role, foreign_key: :subj_rtid, primary_key: :rtid
  belongs_to :member_user, foreign_key: :obj_rtid, primary_key: :rtid, class_name: 'User'
end