# == Schema Information
# Schema version: 20090423194502
#
# Table name: otus
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  taxon_id :integer(8)
#  description :text
#  project_id  :integer
#  creator_id  :integer
#  updator_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  library_id  :string
#  citation_id :integer(8)
#
require 'temp_versioned'
require 'with_name_like'
class Otu < ActiveRecord::Base

  include GenericSearch
  include TempVersioned
  include WithNameLike

  attr_accessor :auto_complete_text_method

  has_many :otu_groups_otus, :class_name => 'OtuGroupsOtus'
#  has_many :otus, :through => :otu_groups_otus
  has_many :otu_groups, :through => :otu_groups_otus

  has_many :otu_images, class_name: 'ImageJoin', as: :object
  has_many :images, :through => :otu_images
  has_and_belongs_to_many :taxa
  has_and_belongs_to_many :citations, :class_name => "Library::Citation"

  has_many :state_codings, :class_name => 'Morphology::StateCoding'
#  has_many :bioentries_otus, :class_name => 'Molecular::BioentriesOtu'
#  has_many :bioentries, :through => :bioentries_otus, :class_name => 'Molecular::Bioentry'

  belongs_to :project
  belongs_to :creator, :class_name => 'User'
  belongs_to :updator, :class_name => 'User'
#  has_one :branch_item, :as => :item
#  belongs_to :matrix_branch, :class_name => 'Matrix::Branch'
#  belongs_to :otu_branch
#  acts_as_list :scope => :otu_branch, :column => 'version'
#  has_many :otus
  has_many :mol_cells, :class_name => 'Molecular::Matrix::Cell'
  has_many :matrices_otus,
           :class_name => "Molecular::Matrix::MatricesOtus",
           :foreign_key => "otu_id"
  validates_presence_of :project_id, :creator_id #:updator_id

  before_save :get_creator_name

#  validates_each :is_static do |record, attr, value|
#    record.errors.add attr, 'cannot edit a static record.'
#  end

#  named_scope :main, :include => :otu_branch, :conditions => "otu_branches.object_history_id is null"

  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }


  def to_s
    self.name
  end

  select_scope :otu_groups_joined, {
    include: { otu_groups: { select: [ 'id', 'name' ]} }
  }
  def otu_groups_joined
    otu_groups.collect(&:name).join(', ')
  end

#  def previous_version
#    otu_branch.otus.find_by_version(version - 1)
#  end
#
#  def next_version
#    otu_branch.otus.find_by_version(version + 1)
#  end

#  def branch
#    otu_branch
#  end

  def Otu.find_all_with_taxon(taxon, project)
    Otu.find_by_sql("select * from otus, otus_taxa where taxon_id = #{taxon.id} and otus.project_id = #{project.id} and otus_taxa.otu_id = otus.id")
  end

  def self.search_name name
    self.find_by_project_id(current_project.id, :conditions => "name ILIKE '%#{name}%'" )
  end


  #TODO could be much better, need to overoverwite method_missing
  def create_clone options = {}, &block
    record = clone
    record.attributes = { updator_id: nil, updated_at: nil }.merge options
    if block_given?
      yield(record)
    end
    record.save!
    record.citations << self.citations
    record.taxa << self.taxa
    record.images << self.images
    record
  end


#  default_scope :conditions => { :is_static => false }

#  def after_save
#    static_copy = clone
#    static_copy.is_static = true
#    static_copy.save!
#    static_copy.taxa << self.taxa.map{|t|t.static_copy.id}
#    static_copy.images << self.images.map{|i|i.static_copy.id}
#  end

#  default_scope :conditions => { :deleted_at => nil }
#
#  def destroy!
#    self.deleted_at = Time.now
#    save!
#  end
#
#  def destroy
#    self.deleted_at = Time.now
#    save
#  end
#
#  def self.destroy_all conditions = nil
#    update_all "deleted_at = now()", conditions
#  end

#  def branch_items_branches
#    branch_item.branch_items_branches
#  end



#  # params_hash represents changes you want to make between new and old versions
#  def create_new_version(params_hash = {}) #branch_id
#    Otu.transaction do
#      new_obj = self.create_clone
#      new_obj.update_attributes!(params_hash)
#      self.timeline.otus << new_obj # ???
#      new_obj
#    end
#  end

  def equivalent_in(otus)
    otus.each do |otu|
      return otu if otu.name.downcase.gsub(/[\s\(\)\-\/]/, '') == name.downcase.gsub(/[\s\(\)\-\/]/, '')
    end
    nil
  end

  # adds one or a group of otus to a matrix by way of a changeset.  this method checks that otus being added are unique
  # and adds a personal copy of each otu to the array.  returns current_otus with otus_to_add included
  def self.add_to_matrix(current_otus, otus_to_add, changeset)
    # terminate add operation if otu is found that has a name collision with a otu already in the matrix
    otus_added = [ ]
#    removed and added if statement
#    otus_to_add.each do |otu_to_add|
#      unless current_otus.select{ |cur_otu| cur_otu.name == otu_to_add.name }.empty?
#        raise "No otus added. Otu '#{otu_to_add.name}' has the same name as another otu in the matrix."
#      end
#    end

    Otu.transaction do
      otus_to_add.each do |otu_to_add|
        #otu_copy = otu_to_add.local_matrix_copy_for(changeset.address.object_history) || otu_to_add.create_local_matrix_copy_for(changeset.address.object_history)
        unless current_otus.include?(otu_to_add)
          changeset.items.create!(:change_type => ChangeTypes::ADD, :new_version => otu_to_add)
          current_otus << otu_to_add
          otus_added << otu_to_add
        end
      end
    end
    [ current_otus, otus_added ]
  end


  # be careful with this! intended only to be used for committing
  def checkpoint_move(checkpoint, prev_position, next_position, should_swap)
    move_item = Morphology::MatricesOtu.find_by_matrix_id_and_otu_id(checkpoint.id, self.id)
    prev_item = should_swap ? Morphology::MatricesOtu.find_by_matrix_id_and_position(checkpoint.id, next_position) : nil
    prev_item.insert_at(prev_position) if prev_item
    move_item.insert_at(next_position)
  end

  # be careful with this! intended only to be used for committing
  def checkpoint_add(checkpoint)
    checkpoint.matrices_otus.create!(:otu => self)
    self.update_attributes!(is_working_copy: false) if self.is_working_copy
  end

  # be careful with this! intended only to be used for committing
  def checkpoint_remove(checkpoint)
    checkpoint.matrices_otus.find_by_otu_id(self.id).destroy
  end

  # be careful with this! intended only to be used for committing
  def checkpoint_replace(checkpoint, old_otu)
    Morphology::MatricesOtu.find_by_matrix_id_and_otu_id(checkpoint.id, old_otu.id).update_attributes!(:otu_id => self.id)
    self.update_attributes!(is_working_copy: false) if self.is_working_copy
  end

  # create a local otu corresponding to the current otu and matrix history
#  def create_local_matrix_copy_for(matrix_history)
#    self.transaction do
#      otu_branch = OtuBranch.create!(:derived_from_otu => self, :object_history => matrix_history)
#      @otu_copy = self.clone { |rec| rec.otu_branch = otu_branch }
#      @otu_copy.update_attributes!(:version => 1, :otu_branch => otu_branch)
#    end
#    @otu_copy
#  end

  # retrieve a local otu corresponding to the current otu and matrix history if it exists
#  def local_matrix_copy_for(matrix_history)
#    otu_branch = OtuBranch.find_by_derived_from_otu_id_and_object_history_id(id, matrix_history.id)
#    otu_branch ? otu_branch.otus.find_by_version(1) : nil
#  end

#  def otu_groups
#    otu_groups_otus.collect{|i| i.otu_group}
#  end

  # [ "name",  "description", "otu groups" ]
  private
    def self.searchable_columns
      @searchable_columns  ||= get_searchable_columns
    end

    def self.get_searchable_columns
      search_columns =  [ "name",  "description" ].inject([]) {| filters ,col_name|  filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s } }
#      search_columns << { "name" => "otu_groups_id", "type" => "integer"}  problematic - no search available on multi-id foreign key columns at present time
    end

    def get_creator_name
      self.creator_name = self.creator.name
    end
end
