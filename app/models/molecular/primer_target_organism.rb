class Molecular::TargetOrganism < ActiveRecord::Base
  include GenericSearch

  default_scope :order => 'id'

  self.table_name = 'primer_target_organisms'

  belongs_to :project
  has_many   :primers
  


end
