class Morphology::ChrState < ActiveRecord::Base
  
  belongs_to :character, :class_name => "Morphology::Character"
  belongs_to :citation, :class_name => "Library::Citation", :foreign_key => "citation_id"
  has_and_belongs_to_many :citations, :class_name => "Library::Citation"
  has_many :chr_state_images, class_name: 'ImageJoin', as: :object
  has_many :images, :through => :chr_state_images
  
  def self.polarities
    ['','none','plesiomorphic','apomorphic','ambiguous']
  end
  
  belongs_to  :creator, :class_name => "User"
  belongs_to  :updator, :class_name => "User"

  validates_presence_of :character_id
  # BELOW LINE WAS CAUSING PROBLEMS IF USER TRYING TO REARRANGE CHR STATES - DONT USE UNLESS ABSOLUTELY NECESSARY - ChrisG
  #validates_uniqueness_of :name, :scope => :character_id, :allow_nil => true, :allow_blank => true

end
