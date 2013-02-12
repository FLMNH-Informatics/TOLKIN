class Morphology::CharactersChrGroups < ActiveRecord::Base
  belongs_to :chr_group, :class_name => 'Morphology::ChrGroup'
  belongs_to :character, :class_name => 'Morphology::Character'
  acts_as_list :scope => :chr_group
end