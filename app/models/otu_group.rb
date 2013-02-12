# == Schema Information
# Schema version: 20090423194502
#
# Table name: otu_groups
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  creator_id :integer
#  updator_id :integer
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer(8)
#

class OtuGroup < ActiveRecord::Base
  include GenericSearch
  #has_many :otu_group_otus
  #has_many :otus, :through => :otu_group_otus
  belongs_to :project

  has_many :otu_groups_otus,
           :order => 'position',
           :class_name => 'OtuGroupsOtus',
           :conditions => "position IS NOT NULL"  ##IMPORTANT because the default scope in otu_groups_otus model doesn't carry over through this association

  has_many :otus,
           :through => :otu_groups_otus

  has_many :molecular_matrices_otu_groups, :class_name => 'Molecular::Matrix::MolecularMatricesOtuGroups' ,  :foreign_key => 'otu_group_id'
  belongs_to :user
  belongs_to :creator, :class_name => 'User'
  belongs_to :updator, :class_name => 'User'

  validates_uniqueness_of :name, :scope => :project_id, :message => 'Otu Group with that name already exists, Please choose a different name.'
  validates_presence_of :name, :message => "of OTU Group can not be blank!"

  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }


  #searchable_columns = [ "name",  "otu" ]

  def otus_in_list
    self.otu_groups_otus.map{|ogo|ogo.otu}
  end
  private
  def self.searchable_columns
    @searchable_columns  ||= [ "name" ].inject([]) {| filters ,col_name|  filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s } }
  end
end
