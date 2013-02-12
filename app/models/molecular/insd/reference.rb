#class Molecular::Insd::Reference < ActiveRecord::Base
#  self.primary_key = 'pk'
#  self.table_name = 'insd_reference'
#
#  belongs_to :xref, class_name: 'Insd::Xref'
#
#  has_and_belongs_to_many :seqs,
#    class_name: 'Insd::Seq',
#    join_table: 'insd_seq_references',
#    foreign_key: 'reference_pk',
#    association_foreign_key: 'seq_pk'
#
#  has_and_belongs_to_many :authors,
#    class_name: 'Insd::Author',
#    join_table: 'insd_reference_authors',
#    foreign_key: 'reference_pk',
#    association_foreign_key: 'author_pk'
#
#  def label
#    "#{title} #{journal}"
#  end
#end
