class Molecular::Alignment::AlignmentSeq < ActiveRecord::Base
  self.table_name = 'alignment_seqs'

  belongs_to :sequence,  :class_name => 'Molecular::Insd::Seq', :foreign_key => 'seq_id'
  belongs_to :alignment, :class_name => 'Molecular::Alignment'

  scope :for_project, lambda { |project| { :conditions => [ "project_id = ?", project.project_id ]}}
  
end