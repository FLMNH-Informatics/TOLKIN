class Molecular::PurificationMethod < ActiveRecord::Base
  include GenericSearch

#   default_scope :order => 'id'

  self.table_name = 'primer_purification_methods'

  belongs_to :project
  has_many   :primers

  scope :for_project, lambda { |project| { :conditions => ["project_id = ?", project.project_id] } }


end
