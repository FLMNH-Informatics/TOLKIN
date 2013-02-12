class Molecular::Matrix::Cell::Status < ActiveRecord::Base
  self.table_name = 'mol_matrix_statuses'
  belongs_to :project, :foreign_key => :project_id
  scope :for_project, lambda { |project|
    { :conditions => ["project_id = ?", project.project_id] }
  }
end
