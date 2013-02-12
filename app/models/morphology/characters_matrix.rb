# == Schema Information
# Schema version: 20090605174655
#
# Table name: characters_matrices
#
#  character_id        :integer
#  matrix_id           :integer
#  position            :integer
#  updated             :boolean
#  new_flag            :boolean
#  marked_for_deletion :boolean
#  id                  :integer(8)      not null, primary key
#

class Morphology::CharactersMatrix < ActiveRecord::Base
  belongs_to :checkpoint, :class_name => "Morphology::Matrix::Checkpoint", :foreign_key => 'matrix_id'
  belongs_to :character, :class_name => "Morphology::Character"

  acts_as_list :scope => :matrix
end