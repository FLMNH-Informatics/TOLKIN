class Library::Author < ActiveRecord::Base
  include GenericSearch
  
  has_many :contributorships
  has_one :project

  def self.search_name name
    self.find_by_project_id(current_project.id, :conditions => "name ILIKE '%#{name}%'" )
  end

  def to_s
    self.name
  end
  
end