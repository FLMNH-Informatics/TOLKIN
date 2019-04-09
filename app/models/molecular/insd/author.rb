class Molecular::Insd::Author < ActiveRecord::Base
  self.primary_key = 'pk'
  self.table_name = 'insd_author'

  has_and_belongs_to_many :references,
    class_name: 'Insd::Reference',
    join_table: 'insd_reference_authors',
    foreign_key: 'author_pk',
    association_foreign_key: 'reference_pk'
end