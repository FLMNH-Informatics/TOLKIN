class Molecular::Insd::Seq::SecondaryAccn < ActiveRecord::Base
  self.table_name = 'insd_seq_secondary_accn'
  self.primary_key = 'pk'

  belongs_to :seq, class_name: 'Insd::Seq', foreign_key: 'insd_seq_pk'
end