# == Schema Information
# Schema version: 20090605174655
#
# Table name: dna_samples
#
#  id                  :integer(8)      not null, primary key
#  taxon_id_old     :integer(8)
#  collection_id_old   :integer(8)
#  sample_nr           :string
#  sample_type         :string
#  amount              :string
#  deposited           :string
#  date_received       :date
#  date_extracted      :date
#  extraction_protocol :string
#  source              :string
#  private_source      :string
#  team                :string
#  notes               :string
#  created_at          :date
#  creator_id_old      :integer(8)
#  updated_at          :date
#  updator_id_old      :integer(8)
#  guid                :string
#  loc_freezer         :string
#  loc_shelf_bin       :string
#  loc_rack_bag        :string
#  loc_box             :string
#  loc_column          :string
#  loc_row             :string
#  project_id          :integer(8)
#  taxon_id         :integer
#  collection_id       :integer
#  creator_id          :integer
#  updator_id          :integer
#  recpermission_id    :integer         default(1)
#

class Molecular::DnaSample < ActiveRecord::Base
  include GenericSearch
  
 # default_scope :order => 'id'

  belongs_to :project
  belongs_to :taxon
  belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'taxon_id'
  belongs_to :recpermission
  belongs_to :creator, :class_name => "Person"
  belongs_to :updater, :class_name => "Person", :foreign_key => 'updator_id'
  belongs_to :collection

  belongs_to :collection_minimal, :class_name => 'Collection', :foreign_key => 'collection_id', :select => 'id, collector, collection_number'
  belongs_to :creator_minimal, :class_name => 'Person', :foreign_key => 'creator_id', :select => 'id, collector, collection_number'
#  belongs_to :taxon_minimal, :class_name => 'Taxon', :foreign_key => 'taxon_id', :select => 'id, name, author, year' TODO: UPDATE TO REFLECT LATEST LABEL CONTENTS
  
  scope :with_taxon_name, lambda { |value| {
      include: 'taxon',
      conditions: [ 'taxa.name ilike ?', "%#{value}%" ]}}
  
  def has_edit_level_permissions?
    if recpermission
      recpermission.name.upcase == Recpermission.edit.upcase
    else
      return true
    end
  end

  def has_delete_level_permissions?
    if recpermission
      recpermission.name.upcase == Recpermission.delete.upcase
    else
      return true
    end
  end

  def can_edit?(id)
    has_edit_level_permissions? || has_delete_level_permissions? || creator_id == id
  end

  def can_delete?(id)
    has_delete_level_permissions? || creator_id == id
  end

    # ["amount",  "collection_id", "deposited", "extraction_protocol", "guid", "loc_box", "loc_column", "loc_freezer", "loc_rac_bag", "log_row", "loc_shelf_bin", "notes", "notes", "samle_nr", "sample_type", "source", "taxon_id", "team" ]
  private

  def self.searchable_columns
    @searchable_columns  ||= get_searchable_columns
    @searchable_columns.unshift(@searchable_columns.delete(@searchable_columns.find{|c| c['name']=="taxon_id"})) #Shifting taxon to be the first item in the array (as requested by euphorbia people on 06/29/2010) - ChrisG
  end
  def self.get_searchable_columns
    [ "amount",  "collection_id", "deposited", "extraction_protocol", "guid", "loc_box", "loc_column", "loc_freezer", "loc_rack_bag", "loc_row", "loc_shelf_bin", "notes", "sample_nr", "sample_type", "source", "taxon_id", "team" ].inject([])  do | filters ,col_name|
      raise "filter not found: #{col_name}" unless columns_hash[col_name]
      filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s }
    end
    #search_columns << { "name" => "otu_groups_id", "type" => "integer"}
  end
end
