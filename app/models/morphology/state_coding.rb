# == Schema Information
# Schema version: 20090605174655
#
# Table name: state_codings
#
#  id           :integer         not null, primary key
#  character_id :integer         not null
#  matrix_id    :integer
#  otu_id       :integer         not null
#  status       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  codings      :string
#  updated_flag :boolean
#  creator_id   :integer
#  updater_id   :integer
#

class Morphology::StateCoding < ActiveRecord::Base
  belongs_to :character, :class_name => "Morphology::Character"
  belongs_to :checkpoint, :class_name => "Morphology::Matrix::Checkpoint", :foreign_key => 'matrix_id'
  belongs_to :otu
  belongs_to :project

  validates_each :character_id, :otu_id, :allow_blank => false do |record, attr, value|
    begin
#      debugger
      case attr
        when :character_id then record.project.characters.find(value) || fail
        when :otu_id then record.project.otus.find(value) || fail
      end
    rescue
#      debugger
      record.errors.add attr, 'is not present in current project.'
    end
  end

  has_many :state_coding_images, class_name: 'ImageJoin', as: :object
  has_many :images, :through => :state_coding_images
  has_and_belongs_to_many :citations, :class_name => "Library::Citation"
  belongs_to :creator, :class_name => 'User'
  belongs_to :updator, :class_name => 'User'
  belongs_to :matrix, :class_name => 'Morphology::Matrix::Checkpoint'

  def create_clone(attributes = nil)
    new_coding = self.clone
    new_coding.update_attributes!(attributes) unless attributes.nil?
    new_coding.images << self.images
    new_coding
  end

  # Be careful with this!  Currently being used only in process of commit.
  def checkpoint_remove(checkpoint)
    checkpoint.state_codings.find_by_character_id_and_otu_id(self.character_id , self.otu_id).update_attributes!(:matrix_id => nil)
  end

  # Be careful with this!  Currently being used only in process of commit.
  def checkpoint_replace(checkpoint, old_coding_analogue)
    if old_coding_analogue
      old_coding = checkpoint.state_codings.find_by_character_id_and_otu_id(old_coding_analogue.character_id , old_coding_analogue.otu_id) # old coding may not be exactly the one recorded in the changeset. be flexible
      old_coding.update_attributes!(:matrix_id => nil) if old_coding
    end
    self.update_attributes!(:matrix_id => checkpoint.id)
  end
end
