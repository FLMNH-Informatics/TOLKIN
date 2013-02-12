# == Schema Information
# Schema version: 20090605174655
#
# Table name: seqfeature
#
#  seqfeature_id  :integer         not null, primary key
#  bioentry_id    :integer         not null
#  type_term_id   :integer         not null
#  source_term_id :integer         not null
#  display_name   :string(64)
#  rank           :integer         default(0), not null
#

class Molecular::Seqfeature < ActiveRecord::Base
  self.primary_key = 'seqfeature_id'
  self.table_name = 'seqfeature'

  belongs_to :bioentry, :class_name => "Molecular::Bioentry"
  belongs_to :type, :class_name => 'Term', :foreign_key => 'type_term_id'
  has_many :seqfeature_qualifier_values, :class_name => "Molecular::SeqfeatureQualifierValue"
end
