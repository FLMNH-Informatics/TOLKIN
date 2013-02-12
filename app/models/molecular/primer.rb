# == Schema Information
# Schema version: 20100609182125
#
# Table name: primers
# COLUMNS =>
# id
# name
# target_organism
# sequence
# primers_storage_id
# molecular_weight
# purification_method
# tm
# pmol
# e260
# in_stock
# notes
# primer_genes_id
# project_id
# created_at
# creator_id
# updated_date
# updater_id
#


class Molecular::Primer < ActiveRecord::Base
  include GenericSearch

  default_scope :order => 'id'
  
  self.table_name = 'primers'
  
  belongs_to :project
  belongs_to :marker, class_name: 'Molecular::Marker'
  belongs_to :taxon, primary_key: :rtid, foreign_key: :taxon_rtid, class_name: 'Taxon'
#   belongs_to :target_organism, class_name: Molecular::TargetOrganism, :foreign_key => 'primer_target_organisms_id'
  belongs_to :purification_method, class_name: 'Molecular::PurificationMethod', :foreign_key => 'purification_method_id'
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
  

  validates_numericality_of :molecular_weight, :allow_nil => true
 # validates_presence_of :name, :allow_blank => false
  scope :for_project, lambda { |project| { :conditions => ["project_id = ?", project.project_id] } }


  private

  def self.searchable_columns
     @searchable_columns  ||= get_searchable_columns
  end

  def self.get_searchable_columns

     search_columns =  [ "name",  "molecular_weight", "tm", "pmol", "storage_box", "storage_row", "storage_col"].inject([]) do |filters, col_name|
#      search_columns =  [ "name",  "primer_target_organisms_id", "molecular_weight", "primer_purification_methods_id","tm", "pmol", "storage_box", "storage_row", "storage_col"].inject([])  do | filters ,col_name|
        raise "filter not found: #{col_name}" unless columns_hash[col_name]
        filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s }
     end
  end
end
