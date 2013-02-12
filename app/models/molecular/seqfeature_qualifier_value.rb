# == Schema Information
# Schema version: 20090605174655
#
# Table name: seqfeature_qualifier_value
#
#  seqfeature_id :integer         not null
#  term_id       :integer         not null
#  rank          :integer         default(0), not null
#  value         :text            not null
#

class Molecular::SeqfeatureQualifierValue < ActiveRecord::Base
  self.table_name = 'seqfeature_qualifier_value'

  belongs_to :seqfeature, :class_name => "Molecular::Seqfeature"
  belongs_to :term
end
