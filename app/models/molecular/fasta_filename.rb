class Molecular::FastaFilename < ActiveRecord::Base
  belongs_to :project, class_name: 'Project', foreign_key: 'project_id'
  has_many :seqs, class_name: 'Molecular::Insd::Seq', foreign_key: 'fasta_filename_id'

  scope :for_project, lambda { |project| { :conditions => ["project_id = ?", project.project_id], :order => 'filename, upload_date desc'}}
end
