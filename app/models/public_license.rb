class PublicLicense < ActiveRecord::Base

  has_many :projects

  def self.generic_licenses
    self.where("project_id IS NULL")
  end

  def self.generic_license_ids
    #outputs array of ids for the standard licenses
    self.all(:select => 'id',:conditions => 'project_id IS NULL').map(&:id)
  end

  def self.create(pid,name,description='',url='')
     self.create(:project_id => pid, :name => name, :description => description, :url => url)
  end
end