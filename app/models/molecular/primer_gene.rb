# == Schema Information
# Schema version: 20100609182125
#
# Table name: primer_genes
# =>app. support table
# COLUMNS =>
# id
# name
#
#

class Molecular::PrimerGene < ActiveRecord::Base
  self.table_name = 'primer_genes'
  has_many :primer
  belongs_to :project, :foreign_key => :project_id
end
