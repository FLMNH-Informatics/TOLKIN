class Statement < Record
  belongs_to :property, :primary_key => :rtid, :foreign_key => :prop_rtid
  belongs_to :object_user, class_name: 'User', primary_key: :rtid, foreign_key: :obj_rtid
  belongs_to :subject_role, class_name: 'Role', primary_key: :rtid, foreign_key: :subj_rtid
end