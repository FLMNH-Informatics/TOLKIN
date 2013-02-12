class Molecular::Insd::Seq::SeqMarker < ActiveRecord::Base
  self.table_name = 'insd_seq_markers'

  belongs_to :marker, :class_name => 'Molecular::Marker'
  belongs_to :sequence, :class_name => 'Molecular::Insd::Seq'
  belongs_to :seq, :class_name => 'Molecular::Insd::Seq'

  scope :for_project, lambda { |project| { :conditions => ["project_id = ?", project.project_id]}}

  before_save :update_sequence_markers_fulltext

  def update_sequence_markers_fulltext
    self.seq.update_markers_fulltext
    self.seq.save
  end

end