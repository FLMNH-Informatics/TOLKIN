class Molecular::Alignment::AlignmentOutputs < ActiveRecord::Base
  self.table_name = 'alignment_outputs'

  belongs_to :alignment, :class_name => 'Molecular::Alignment', :foreign_key => 'alignment_id'

  scope :for_project, lambda {|project| { :conditions => [ "project_id = ?", project.project_id ]}}

  def new type
    debugger
    return 'test'
  end
end