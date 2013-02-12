class Note < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  belongs_to :author, :class_name => 'User'
  acts_as_list :scope => :item
end
