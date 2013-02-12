class Morphology::Matrix::MorphologyMatricesOtuGroups < ActiveRecord::Base

  belongs_to :matrix_checkpoint, :class_name => "Morphology::Matrix::Checkpoint" ,  :foreign_key => "matrix_checkpoint_id"
  belongs_to :otu_group, :class_name => "OtuGroup",  :foreign_key => 'otu_group_id'
  belongs_to :creator, :class_name => "User",  :foreign_key => 'creator_id'

  self.table_name = "matrices_otu_groups"

  def self.add_otu_group_to_matrix input    
    record = Morphology::Matrix::MorphologyMatricesOtuGroups.new(input)
    record.save!
  end
  
  def self.update_color id , color
    Morphology::Matrix::MorphologyMatricesOtuGroups.update(id, :color => color)
  end
  
end
