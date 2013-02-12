class Chromosome::Dye < ActiveRecord::Base
  include GenericSearch

  has_many :hybridizations

  scope :for_project, lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }

end
