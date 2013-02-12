# == Schema Information
# Schema version: 20090605174655
#
# Table name: biosequence
#
#  bioentry_id :integer         not null
#  version     :integer
#  length      :integer
#  alphabet    :string(10)
#  seq         :text
#

class Molecular::Biosequence < ActiveRecord::Base
  self.table_name = "biosequence"
  self.primary_key = "bioentry_id"
  belongs_to :bioentry, :class_name => "Molecular::Bioentry"
end
