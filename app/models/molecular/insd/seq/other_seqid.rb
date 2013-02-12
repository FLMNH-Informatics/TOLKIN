class Molecular::Insd::Seq::OtherSeqid < ActiveRecord::Base
  self.table_name = 'insd_seq_other_seqid'
  self.primary_key = 'pk'

  belongs_to :seq, foreign_key: 'insd_seq_pk', primary_key: 'pk'
end
