class Library::Publication < ActiveRecord::Base
  self.table_name = 'l_publications'
  self.primary_key = 'l_publication_id'
  belongs_to :parent, :class_name => "Library::Publication", :primary_key => 'l_publication_id'
  belongs_to :project
  #belongs_to :user
  #belongs_to :updator, :class_name => "User"

  belongs_to :creator, class_name: 'User'
  belongs_to :deleter, class_name: 'User'

  def to_s
    value
  end
end