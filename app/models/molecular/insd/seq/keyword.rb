class Molecular::Insd::Seq::Keyword < ActiveRecord::Base
  self.primary_key = 'pk'
  self.table_name = 'insd_seq_keyword'

  belongs_to :seq, class_name: 'Insd::Seq', foreign_key: 'insd_seq_pk'
end