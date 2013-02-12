class Molecular::SeqMarkers < ActiveRecord::Base
  self.table_name = 'insd_seq_markers'

  belongs_to :marker, :class_name => Molecular::Marker
  belongs_to :sequence, :class_name => Molecular::Insd::Seq

  scope :for_project, lambda { |project| { :conditions => ["project_id = ?", project.project_id]}}
  
end