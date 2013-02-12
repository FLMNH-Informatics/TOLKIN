class Library::Contributorship   < ActiveRecord::Base
  #belongs_to :person, :class_name => "Person"
  belongs_to :citation, :class_name => "Library::Citation"
  belongs_to :author, :class_name => "Library::Author"
  #validates_presence_of :person_id, :citation_id, :pen_name_id
  validates_uniqueness_of :citation_id, :scope => :author_id
end
