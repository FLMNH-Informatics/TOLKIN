class Morphology::MatricesOtu < ActiveRecord::Base

  belongs_to :checkpoint, :class_name => "Morphology::Matrix::Checkpoint", :foreign_key => 'matrix_id'
  belongs_to :otu


  acts_as_list :scope => :matrix
end