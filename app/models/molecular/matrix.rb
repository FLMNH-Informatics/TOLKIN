class Molecular::Matrix < ActiveRecord::Base
  include GenericSearch

  has_many :timelines,
           :class_name  => 'Molecular::Matrix::Timeline',
           :foreign_key => 'matrix_id',
           :order       => 'updated_at'

  belongs_to :project
  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }

  self.table_name = 'molecular_matrices'





end
